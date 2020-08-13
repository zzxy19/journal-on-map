import 'package:flutter/material.dart';

import 'journal_manager.dart';
import 'google_map_location_util.dart';
import 'proto.dart';
import 'api_key.dart';
import 'page_config.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

/// Create/Edit journal page.
/// If no journalId is passed in (is null), this page will create a new journal
/// with a new id upon save. If a journalId is passed in, this page serves as
/// editing of the existing journal with the corresponding id.
class CreateJournalPage extends StatefulWidget {
  CreateJournalPage(this.initialState, {Key key}) : super(key: key);
  final CreateJournalPageInitialState initialState;
  @override
  CreateJournalPageState createState() => CreateJournalPageState(initialState);
}

class CreateJournalPageState extends State<CreateJournalPage> {
  final _journalManager = JournalManager.manager;
  final titleTextController = TextEditingController();
  final contentTextController = TextEditingController();
  final locationTextController = TextEditingController();
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final CreateJournalPageInitialState initialState;

  Future<Journal> _existingJournalFuture;
  JournalMetadata _existingJournalMetadata;
  bool pageLoaded = false;
  Location _selectedLocation;
  bool fetchingLocation = false;

  CreateJournalPageState(this.initialState);

  @override
  void initState() {
    super.initState();
    switch (initialState.journalType) {
      case JournalType.EDIT_EXISTING:
        _existingJournalFuture = _journalManager.getJournal(initialState.journalId);
        return;

      case JournalType.NEW_WITH_LOCATION:
        _getAndSetLocation(initialState.coordinate);
        break;

      case JournalType.NEW:
        locationTextController.text = "[empty]";
        break;

      default:
        // do nothing
    }
    pageLoaded = true;
  }

  void _getAndSetLocation(Coordinate coordinate) async {
    setState(() {
      fetchingLocation = true;
      locationTextController.text = "Getting location name...";
    });
    String locationName;
    try {
      locationName = await _getAddressFromCoordinate(coordinate);
    } catch (exception) {
      _setLocation(coordinate, "A mysterious place");
      fetchingLocation = false;
      return;
    }
    _setLocation(coordinate, locationName);
    fetchingLocation = false;
  }

  void _setLocation(Coordinate coordinate, String locationName) {
    setState(() {
      _selectedLocation = Location(name: locationName, coordinate: coordinate);
      locationTextController.text = locationName;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleTextController.dispose();
    contentTextController.dispose();
    locationTextController.dispose();
    super.dispose();
  }

  void _saveJournal(BuildContext context) async {
    if (_selectedLocation == null || fetchingLocation) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Missing location"),
              content: Text("You need to select a location to save the current note."));
        },
      );
      return;
    }
    JournalContent content = _buildJournalContent(contentTextController.text);
    Journal journal = Journal();
    journal.content = content;
    _selectedLocation.name = locationTextController.text;

    switch (initialState.journalType) {
      case JournalType.EDIT_EXISTING:
        journal.metadata = _updateExistingJournalMetadata();
        await _journalManager.updateJournal(journal);
        break;

      case JournalType.NEW:
      case JournalType.NEW_WITH_LOCATION:
        journal.metadata = _prepareNewJournalMetadata();
        await _journalManager.insertJournal(journal);
        break;
    }
    _toast("Saved!");
    Navigator.of(context).pop(/* shouldRefresh */ true);
  }

  void _deleteJournal(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Deleting note?"),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () async {
                await _journalManager.deleteJournal(initialState.journalId);
                _toast("Deleted!");
                Navigator.of(context).pop();
                Navigator.of(context).pop(/* shouldRefresh */ true);
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
    if (initialState.journalType == JournalType.EDIT_EXISTING && !pageLoaded) {
      return FutureBuilder<Journal>(
        future: _existingJournalFuture,
        builder: (BuildContext context, AsyncSnapshot<Journal> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text("Loading note...");
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
    locationTextController.text = journal.metadata.location.name;
  }

  /// Deprecated
  ///
  /// This API doesn't seem to be stable/performant, so I've cut it out.
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
    if (location.name == null) {
      await _getAndSetLocation(location.coordinate);
    } else {
      _setLocation(location.coordinate, location.name);
    }
  }

  void _getUserCurrentLocation() async {
    setState(() {
      fetchingLocation = true;
      locationTextController.text = "Fetching your current location...";
    });
    // Using #getLastKnownPosition instead of #getCurrentPosition because it
    // seems much faster.
    Position position;
    try {
      position = await geolocator.getLastKnownPosition();
    } catch (exception) {
      _setLocation(Coordinate(), "Unable to get location");
      fetchingLocation = false;
      return;
    }
    _getAndSetLocation(GoogleMapLocationUtil.position2Coordinate(position));
    fetchingLocation = false;
  }

  Future<String> _getAddressFromCoordinate(Coordinate coordinate) async {
    List<Placemark> places =
        await geolocator.placemarkFromCoordinates(coordinate.latitude, coordinate.longitude);
    Placemark place = places[0];
    return "${place.locality}, ${place.postalCode}, ${place.country}";
  }

  _toast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Theme.of(context).accentColor,
        textColor: Colors.black,
        fontSize: 16.0
    );
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
                Expanded(
                  child: TextField(
                    controller: locationTextController,
                    decoration: InputDecoration(
                      border:InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            TextField(
              controller: contentTextController,
              minLines: 30, // make the empty text area clickable
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Note",
                border:InputBorder.none,
              ),
            ),],
        ).toList(),
    );
  }

  List<Widget> _getFABs(BuildContext context) {
    switch (initialState.journalType) {
      case JournalType.EDIT_EXISTING:
        return <Widget>[
          FloatingActionButton(
            heroTag: "save-btn",
            onPressed: () => {_saveJournal(context)},
            tooltip: 'Save note',
            child: Icon(Icons.check),
          ),
          FloatingActionButton(
            heroTag: "delete-btn",
            onPressed: () => {_deleteJournal(context)},
            tooltip: 'Delete note',
            child: Icon(Icons.delete),
          ),
        ];

      default:
        return <Widget>[
          FloatingActionButton(
            heroTag: "save-btn",
            onPressed: () => {_saveJournal(context)},
            tooltip: 'Save note',
            child: Icon(Icons.check),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Notebook'),
      ),
      body: _buildJournalPage(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _getFABs(context),
      ),
    );
  }
}
