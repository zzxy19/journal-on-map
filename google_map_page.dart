import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'home.dart';
import 'journal_manager.dart';
import 'google_map_location_util.dart';
import 'proto.dart';

class GoogleMapPage extends StatefulWidget {
  GoogleMapPage({Key key}) : super(key: key);

  @override
  GoogleMapPageState createState() =>
      GoogleMapPageState();
}

class GoogleMapPageState extends State<GoogleMapPage> {

  Completer<GoogleMapController> _controller = Completer();
  Future<List<JournalMetadata>> _journalMetadataList;
  JournalManager _journalManager = JournalManager.manager;

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  _loadJournalEntries() async {
    _journalMetadataList = _journalManager.listJournalMetadata();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<JournalMetadata>>(
      future: _journalMetadataList,
      builder: (BuildContext context, AsyncSnapshot<List<JournalMetadata>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text("Loading journal list...");
          default:
            if (snapshot.hasError) {
              return Text("Error: " + snapshot.error.toString());
            } else if (!snapshot.hasData) {
              return Text("There was no error but we didn't fetch any data.");
            }
            List<JournalMetadata> metadataList = snapshot.data;
            return Column(
                children: <Widget>[
                  // _buildCalendarSection(),
                  _buildMapSection(metadataList),
                ]);
        }
      },
    );
  }

  Widget _buildCalendarSection() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: Text("Calendar here\n\n\n\nFill this space"),
    );
  }

  Widget _buildMapSection(List<JournalMetadata> metadataList) {
    List<Location> locations = [];
    Set<Marker> markers = Set();
    for (JournalMetadata metadata in metadataList) {
      locations.add(metadata.location);
      markers.add(_buildJournalMarker(metadata));
    }
    CameraPosition cameraPosition = GoogleMapLocationUtil.deduceCameraCenter(locations);
    return Expanded(
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: cameraPosition,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: markers,
        )
      );
  }

  Marker _buildJournalMarker(JournalMetadata metadata) {
    return Marker(
      markerId: MarkerId(metadata.id),
      position: GoogleMapLocationUtil.coordinate2Latlng(metadata.location.coordinate),
      infoWindow:
          InfoWindow(
              title: metadata.title,
              snippet: "Created: " + metadata.createTime.toString(),
              onTap: () => _navigateToCreateJournalPage(metadata.id),),
    );
  }

  void _navigateToCreateJournalPage(String journalId) {
    Navigator.of(context).push(
        MaterialPageRoute(
            builder:
                (context) =>
                HomePage(selectedPageIndex: 1, currentJournalId: journalId)));
  }
}