import 'package:flutter/material.dart';

import 'home.dart';
import 'journal_manager.dart';
import 'google_map_location_util.dart';
import 'proto.dart';
import 'api_key.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// Create/Edit journal page.
/// If no journalId is passed in (is null), this page will create a new journal
/// with a new id upon save. If a journalId is passed in, this page serves as
/// editing of the existing journal with the corresponding id.
class CreateJournalPage extends StatefulWidget {
  CreateJournalPage({Key key, this.journalId,}) : super(key: key);
  final String journalId;
  @override
  CreateJournalPageState createState() => CreateJournalPageState(journalId: journalId);
}

class CreateJournalPageState extends State<CreateJournalPage> {
  final _journalManager = JournalManager.manager;
  final titleTextController = TextEditingController();
  final contentTextController = TextEditingController();
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final String journalId; // null -> new journal; non-null -> edit existing journal
  Future<Journal> _existingJournalFuture;
  JournalMetadata _existingJournalMetadata;
  Location _selectedLocation;
  bool pageLoaded = false;
  String _locationText = "[empty]";

  CreateJournalPageState({this.journalId});

  @override
  void initState() {
    super.initState();
    if (journalId != null) {
      _existingJournalFuture = _journalManager.getJournal(journalId);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleTextController.dispose();
    contentTextController.dispose();
    super.dispose();
  }

  void _saveJournal(BuildContext context) async {
    if (_selectedLocation == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Missing location"),
              content: Text("You need to select a location to save the current journal."));
        },
      );
      return;
    }
    JournalContent content = _buildJournalContent(contentTextController.text);
    Journal journal = Journal();
    journal.content = content;
    if (journalId == null) {
      journal.metadata = _prepareNewJournalMetadata();
      await _journalManager.insertJournal(journal);
    } else {
      journal.metadata = _updateExistingJournalMetadata();
      await _journalManager.updateJournal(journal);
    }
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => HomePage(selectedPageIndex: 2,)));
  }

  JournalContent _buildJournalContent(String text) {
    return JournalContent.fromPlainText(text);
  }

  JournalMetadata _updateExistingJournalMetadata() {
    _existingJournalMetadata.title = titleTextController.text;
    _existingJournalMetadata.updateTime = Timestamp.current();
    _existingJournalMetadata.location = _selectedLocation;
    return _existingJournalMetadata;
  }

  JournalMetadata _prepareNewJournalMetadata() {
    String uniqueId = "1:" + DateTime.now().millisecondsSinceEpoch.toString();
    JournalMetadata journalMetadata = JournalMetadata(
        uniqueId,
        titleTextController.text,
        _selectedLocation,
        Timestamp.current(),
        Timestamp.current());
    return journalMetadata;
  }

  Widget _buildJournalPage() {
    if (journalId != null && !pageLoaded) {
      return FutureBuilder<Journal>(
        future: _existingJournalFuture,
        builder: (BuildContext context, AsyncSnapshot<Journal> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text("Loading journal...");
            default:
              if (snapshot.hasError) {
                return Text("Error: " + snapshot.error.toString());
              } else if (!snapshot.hasData) {
                return Text("There was no error but we didn't fetch any data.");
              }
              pageLoaded = true;
              _updateInternalStateFromStoredMetadata(snapshot.data);
              return _journalPageTemplate(context);
          }
        },
      );
    }
    return _journalPageTemplate(context);
  }

  void _updateInternalStateFromStoredMetadata(Journal journal) {
    _existingJournalMetadata = journal.metadata;
    titleTextController.text = journal.metadata.title;
    contentTextController.text = journal.content.plainText();
    _selectedLocation = journal.metadata.location;
    _locationText = journal.metadata.location.name;
  }

  void _getUserSelectedLocation(BuildContext context) async {
    LocationResult result = await showLocationPicker(
        context,
        ApiKey.GOOGLE_MAP_API_KEY,
        initialCenter: LatLng(0, 0),
        initialZoom: 1.0);
    if (result == null) {
      return;
    }
    Location location = GoogleMapLocationUtil.locationResult2Location(result);
    setState(() => _locationText = "Fetching location...");
    String locationName =
        location.name != null ?
            location.name : await _getAddressFromCoordinate(location.coordinate);
    setState(() {
      _selectedLocation = Location(name: locationName, coordinate: location.coordinate);
      _locationText = locationName;
    });
  }

  void _getUserCurrentLocation() async {
    setState(() {
      _locationText = "Fetching your current location...";
    });
    Position position = await geolocator.getCurrentPosition();
    String locationName =
        await _getAddressFromCoordinate(GoogleMapLocationUtil.position2Coordinate(position));
    setState(() {
      _selectedLocation = GoogleMapLocationUtil.position2Location(position, locationName);
      _locationText = _selectedLocation.name;
    });
  }

  Future<String> _getAddressFromCoordinate(Coordinate coordinate) async {
    List<Placemark> p = await geolocator.placemarkFromCoordinates(
        coordinate.latitude, coordinate.longitude);
    Placemark place = p[0];
    return "${place.locality}, ${place.postalCode}, ${place.country}";
  }

  Widget _journalPageTemplate(BuildContext context) {
    return ListView(
        padding: EdgeInsets.only(bottom: 1.0, left: 8.0, right: 8.0),
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            TextField(
              controller: titleTextController,
              decoration: InputDecoration(
                hintText: "Title",
                border:InputBorder.none,
              ),
            ),
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.my_location),
                  onPressed: _getUserCurrentLocation,
                ),
                GestureDetector(
                  onTap: () => _getUserSelectedLocation(context),
                  child: Text(_locationText, style: TextStyle(color: Colors.blue),),
                ),
              ],
            ),
            TextField(
              controller: contentTextController,
              minLines: 30, // make the empty text area clickable
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Journal",
                border:InputBorder.none,
              ),
            ),],
        ).toList(),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildJournalPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_saveJournal(context)},
        tooltip: 'Save journal',
        child: Icon(Icons.check),
      ),);
  }
}
