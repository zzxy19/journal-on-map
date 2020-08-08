import 'package:flutter/material.dart';

import 'list_journal_page.dart';
import 'journal_manager.dart';
import 'proto.dart';

/// Create/Edit journal page.
/// If no journalId is passed in (is null), this page will create a new journal
/// with a new id upon save. If a journalId is passed in, this page serves as
/// editing of the existing journal with the corresponding id.
class CreateJournalPage extends StatefulWidget {
  CreateJournalPage({Key key, this.journalId,}) : super(key: key);
  final int journalId;
  @override
  CreateJournalPageState createState() => CreateJournalPageState(journalId: journalId);
}

class CreateJournalPageState extends State<CreateJournalPage> {
  final _journalManager = JournalManager.manager;
  final titleTextController = TextEditingController();
  final contentTextController = TextEditingController();
  final int journalId; // null -> new journal; non-null -> edit existing journal
  Future<Journal> _existingJournalFuture;
  JournalMetadata _existingJournalMetadata;

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
        MaterialPageRoute(builder: (context) => ListPage()));
  }

  JournalContent _buildJournalContent(String text) {
    return JournalContent.fromPlainText(text);
  }

  JournalMetadata _updateExistingJournalMetadata() {
    _existingJournalMetadata.title = titleTextController.text;
    _existingJournalMetadata.updateTime = Timestamp.current();
    return _existingJournalMetadata;
  }

  JournalMetadata _prepareNewJournalMetadata() {
    int uniqueId = DateTime.now().millisecondsSinceEpoch;
    JournalMetadata journalMetadata = JournalMetadata(
        uniqueId,
        titleTextController.text,
        20.0,
        10.0,
        Timestamp.current(),
        Timestamp.current());
    return journalMetadata;
  }

  Widget _buildJournalPage() {
    if (journalId != null) {
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
              Journal journal = snapshot.data;
              _existingJournalMetadata = journal.metadata;
              titleTextController.text = journal.metadata.title;
              contentTextController.text = journal.content.plainText();
              return _journalPageTemplate();
          }
        },
      );
    } else {
      return _journalPageTemplate();
    }
  }

  Widget _journalPageTemplate() {
    return ListView(
        padding: EdgeInsets.all(8.0),
        children: <Widget>[
          TextField(
            controller: titleTextController,
            decoration: InputDecoration(
                hintText: "Title"
            ),
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
          ),]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Write a journal"),
      ),
      body: _buildJournalPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_saveJournal(context)},
        tooltip: 'Save journal',
        child: Icon(Icons.check),
      ),);
  }
}
