import 'package:flutter/material.dart';

import 'page_config.dart';
import 'journal_manager.dart';
import 'proto.dart';
import 'package:fluttertoast/fluttertoast.dart';


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

  _loadJournalEntries() {
    _journalMetadataList = _journalManager.listJournalMetadata();
  }

  Widget _buildJournalList() {
    return FutureBuilder<List<JournalMetadata>>(
      future: _journalMetadataList,
      builder: (BuildContext context, AsyncSnapshot<List<JournalMetadata>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text("Loading notes...");
          default:
            if (snapshot.hasError) {
              return Text("Error: " + snapshot.error.toString());
            } else if (!snapshot.hasData) {
              return Text("There was no error but we didn't fetch any data.");
            }
            List<JournalMetadata> metadataList = snapshot.data;
            return ListView.separated(
                itemCount: metadataList.length,
                itemBuilder: (BuildContext context, int index) =>
                    _buildJournal(metadataList.elementAt(index), context),
                separatorBuilder: (BuildContext context, int index) => Divider()
            );
        }
      },
    );
  }

  Widget _buildJournal(JournalMetadata journalMetadata, BuildContext context) {
    return Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(),
        ),
        child: ListTile(
          dense: true,
          onTap: () async {
            await RoutingHelper.navigateToEditJournalPage(context, journalMetadata.id);
            setState(() {
              _loadJournalEntries();
            });
          },
          title: Text(journalMetadata.title),
          subtitle: Text(journalMetadata.createTime.toDateString()),
          leading: Icon(Icons.library_books),
          trailing:
              IconButton(
                  padding: EdgeInsets.all(0.0),
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteJournal(journalMetadata.id),)
        ));
  }

  _deleteJournal(String journalId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text("Deleting note?"),
            actions: <Widget>[
              FlatButton(
                child: Text('Yes'),
                onPressed: () async {
                  await _journalManager.deleteJournal(journalId);
                  setState(() {
                    _loadJournalEntries();
                  });
                  _toast("Deleted!");
                  Navigator.of(context).pop();
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

  _toast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity. BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Theme.of(context).accentColor,
        textColor: Colors.black,
        fontSize: 16.0
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return _buildJournalList();
  }
}
