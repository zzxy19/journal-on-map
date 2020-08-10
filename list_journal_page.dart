import 'package:flutter/material.dart';

import 'home.dart';
import 'journal_manager.dart';
import 'proto.dart';

class ListPage extends StatefulWidget {
  ListPage({Key key}) : super(key: key);
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
            if (snapshot.hasError) {
              return Text("Error: " + snapshot.error.toString());
            } else if (!snapshot.hasData) {
              return Text("There was no error but we didn't fetch any data.");
            }
            List<JournalMetadata> metadataList = snapshot.data;
            return ListView.separated(
                padding: EdgeInsets.all(8.0),
                itemCount: metadataList.length,
                itemBuilder: (BuildContext context, int index) =>
                    _buildJournal(metadataList.elementAt(index), context),
                separatorBuilder: (BuildContext context, int index) =>
                    Divider());
        }
      },
    );
  }

  Widget _buildJournal(JournalMetadata journalMetadata, BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          border: Border(bottom: BorderSide()),
        ),
        child: ListTile(
          onTap: () => _navigateToCreateJournalPage(journalMetadata.id),
          title: Text(journalMetadata.title),
          leading: Icon(Icons.mode_edit),));
  }

  void _navigateToCreateJournalPage(String journalId) {
    Navigator.of(context).push(
        MaterialPageRoute(
            builder:
                (context) =>
                    HomePage(selectedPageIndex: 1, currentJournalId: journalId)));
  }

  @override
  Widget build(BuildContext context) {
    return _buildJournalList();
  }
}
