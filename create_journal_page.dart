import 'package:flutter/material.dart';

import 'list_journal_page.dart';
import 'journal_manager.dart';
import 'journal_content_parser.dart';
import 'proto.dart';

/// Create/Edit journal page.
/// If no journalId is passed in (is null), this page will create a new journal
/// with a new id upon save. If a journalId is passed in, this page serves as
/// editing of the existing journal with the corresponding id.
class CreateJournalPage extends StatefulWidget {
  CreateJournalPage({Key key, this.journalId,}) : super(key: key);
  final int journalId;
  @override
  CreateJournalPageState createState() => CreateJournalPageState();
}

class CreateJournalPageState extends State<CreateJournalPage> {
  final _journalManager = JournalManager.manager;
  final titleTextController = TextEditingController();
  final contentTextController = TextEditingController();
  final contentParser = JournalContentParser();
  final int journalId; // null -> new journal; non-null -> edit existing journal

  CreateJournalPageState({this.journalId});

  @override
  void initState() {
    super.initState();
    if (journalId == null) {
      titleTextController.text = "abc";
    } else {
      titleTextController.text = "def";
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    titleTextController.dispose();
    contentTextController.dispose();
    super.dispose();
  }

  Journal prepareJournal() {
    int uniqueId = DateTime.now().millisecondsSinceEpoch;
    JournalMetadata journalMetadata = JournalMetadata(
        uniqueId,
        titleTextController.text,
        20.0,
        10.0,
        Timestamp.current(),
        Timestamp.current());
  }

  void _saveJournal(BuildContext context) {
    Journal journal = prepareJournal();
    _journalManager.insertJournal(journal);
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ListPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Write a journal"),
      ),
      body: ListView(
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
            ),]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_saveJournal(context)},
        tooltip: 'Save journal',
        child: Icon(Icons.check),
      ),);
  }
}
