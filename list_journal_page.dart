import 'package:flutter/material.dart';

import 'create_journal_page.dart';
import 'journal_manager.dart';
import 'proto.dart';

class ListPage extends StatefulWidget {
  ListPage({Key key, this.title,}) : super(key: key);
  final String title;
  @override
  ListPageState createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
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

  Widget _buildJournalList() {
    return FutureBuilder<List<JournalMetadata>>(
      future: _journalMetadataList,
      builder: (BuildContext context, AsyncSnapshot<List<JournalMetadata>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text("Loading journal list...");
          default:
            if (!snapshot.hasData) {
              return Text("Error...");
            }
            return ListView(
                padding: EdgeInsets.all(8.0),
                children:
                    snapshot.data
                        .map(
                            (JournalMetadata journalEntry) =>
                                _buildJournal(journalEntry))
                        .toList());
        }
      },
    );
  }

  Widget _buildJournal(JournalMetadata journalMetadata) {
    return ListTile(
        onTap: () => _navigateToCreateJournalPage(journalId: journalMetadata.id),
        title: Text(journalMetadata.title));
  }

  void _navigateToCreateJournalPage({int journalId}) {
    if (journalId == null) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CreateJournalPage()));
    } else {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CreateJournalPage(journalId: journalId)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List page"),
      ),
      body: _buildJournalList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateJournalPage,
        tooltip: 'Write a new journal',
        child: Icon(Icons.add),
      ),);
  }
}
