import 'package:flutter/material.dart';

import 'create_journal_page.dart';
import 'list_journal_page.dart';
import 'google_map_page.dart';

class HomePage extends StatefulWidget {

  HomePage({Key key, this.currentJournalId, this.selectedPageIndex}) : super(key: key);
  final int selectedPageIndex;
  final String currentJournalId;

  @override
  HomePageState createState() =>
      HomePageState(selectedPageIndex: selectedPageIndex, currentJournalId: currentJournalId);
}

class HomePageState extends State<HomePage> {
  HomePageState({int selectedPageIndex, String currentJournalId}) {
    _pages = <Widget>[
      GoogleMapPage(),
      CreateJournalPage(journalId: currentJournalId,),
      ListPage(),
    ];
    this.selectedPageIndex = selectedPageIndex ?? 0;
    this.currentJournalId = currentJournalId;
  }

  int selectedPageIndex;
  String currentJournalId; // can be null
  List<Widget> _pages;

  void _onItemTapped(int index) {
    setState(() {
      selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Journal on Map'),
        ),
        body: Center(
          child: _pages.elementAt(selectedPageIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              title: Text('Map'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              title: Text('Journal'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              title: Text('List'),
            ),
          ],
          onTap: _onItemTapped,
          currentIndex: selectedPageIndex,
        )
    );
  }
}



