import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'journal_manager.dart';
import 'google_map_location_util.dart';
import 'proto.dart';
import 'page_config.dart';

class GoogleMapPage extends StatefulWidget {
  GoogleMapPage({Key key}) : super(key: key);

  @override
  GoogleMapPageState createState() =>
      GoogleMapPageState();
}

class GoogleMapPageState extends State<GoogleMapPage> {
  static final MarkerId _NEW_JOURNAL_MARKER_ID = MarkerId("new-journal");

  Future<List<JournalMetadata>> _journalMetadataListFuture;
  List<JournalMetadata> _journalMetadataList;
  GoogleMapController _controller;
  Coordinate _longPressedCoordinate;
  double _previousZoom;
  JournalManager _journalManager = JournalManager.manager;

  @override
  void initState() {
    _loadJournalEntries();
    super.initState();
  }

  _loadJournalEntries() {
    _longPressedCoordinate = null;
    _previousZoom = null;
    _journalMetadataList = null;
    _journalMetadataListFuture = _journalManager.listJournalMetadata();
  }

  refreshState() {
    setState(() {
      _loadJournalEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_journalMetadataList == null) {
      return FutureBuilder<List<JournalMetadata>>(
        future: _journalMetadataListFuture,
        builder: (BuildContext context,
            AsyncSnapshot<List<JournalMetadata>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text("Loading notes...");
            default:
              if (snapshot.hasError) {
                return Text("Error: " + snapshot.error.toString());
              } else if (!snapshot.hasData) {
                return Text("There was no error but we didn't fetch any data.");
              }
              _journalMetadataList = snapshot.data;
              return Column(
                  children: <Widget>[
                    _buildMapSection(_journalMetadataList),
                  ]);
          }
        },
      );
    } else {
      return Column(
          children: <Widget>[
            _buildMapSection(_journalMetadataList),
          ]);
    }
  }

  Widget _buildMapSection(List<JournalMetadata> metadataList) {
    List<Location> locations = [];
    Set<Marker> markers = Set();
    for (JournalMetadata metadata in metadataList) {
      locations.add(metadata.location);
      markers.add(_buildJournalMarker(metadata));
    }
    CameraPosition cameraPosition;
    CameraUpdate cameraUpdate;
    if (_longPressedCoordinate != null) {
      markers.add(_buildNewJournalMarker(_longPressedCoordinate));
      cameraPosition = GoogleMapLocationUtil.fromCoordinateAndZoom(_longPressedCoordinate, _previousZoom);
    } else {
      cameraPosition = GoogleMapLocationUtil.initialCameraPosition();
      cameraUpdate = GoogleMapLocationUtil.deduceCameraCenter(locations);
    }
    return Expanded(
      child: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        initialCameraPosition: cameraPosition,
        padding: EdgeInsets.only(top: 20, bottom: 20),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          if (_longPressedCoordinate != null) {
            _controller.showMarkerInfoWindow(_NEW_JOURNAL_MARKER_ID);
          } else if (cameraUpdate != null) {
            _controller.moveCamera(cameraUpdate);
          }
        },
        markers: markers,
        onLongPress: (LatLng latLng) async {
          double zoomLevel = await _controller.getZoomLevel();
          setState(() {
            _longPressedCoordinate = GoogleMapLocationUtil.latlng2Coordinate(latLng);
            _previousZoom = zoomLevel;
          });
        },
      ),
    );
  }

  Marker _buildJournalMarker(JournalMetadata metadata) {
    return Marker(
      markerId: MarkerId(metadata.id),
      position: GoogleMapLocationUtil.coordinate2Latlng(metadata.location.coordinate),
      infoWindow:
          InfoWindow(
              title: metadata.title,
              snippet: metadata.createTime.toString(),
              onTap: () async {
                bool shouldRefresh =
                    await RoutingHelper.navigateToEditJournalPage(context, metadata.id);
                if (shouldRefresh != null) {
                  refreshState();
                }
              },),
    );
  }

  Marker _buildNewJournalMarker(Coordinate coordinate) {
    return Marker(
      markerId: _NEW_JOURNAL_MARKER_ID,
      position: GoogleMapLocationUtil.coordinate2Latlng(coordinate),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow:
          InfoWindow(
              title: "Write a new note!",
              snippet: "\n\n",
              onTap: () async {
                bool shouldRefresh =
                    await RoutingHelper.navigateToNewJournalWithLocationPage(context, coordinate);
                if (shouldRefresh != null) {
                  refreshState();
                }
              },
          ),
    );
  }
}