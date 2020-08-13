import 'package:flutter/material.dart';

import 'create_journal_page.dart';
import 'list_journal_page.dart';
import 'google_map_page.dart';
import 'page_config.dart';

class HomePage extends StatefulWidget {

  HomePage(this.initialState, {Key key}) : super(key: key);
  final HomePageInitialState initialState;

  @override
  HomePageState createState() => HomePageState(initialState);
}

class HomePageState extends State<HomePage> {
  HomePageState(HomePageInitialState initialState) {
    _pages = <Widget>[
      GoogleMapPage(),
      CreateJournalPage(initialState.createJournalPageInitialState),
      ListPage(),
    ];
    this.selectedPageIndex = initialState.selectedPageIndex;
  }

  int selectedPageIndex;
  List<Widget> _pages;

  void _onItemTapped(int index) async {
    if (index == 1) {
      bool shouldRefresh = await RoutingHelper.navigateToNewJournalPage(context);
      if (shouldRefresh != null) {
        _forceRefresh(selectedPageIndex);
      }
    } else {
      setState(() {
        selectedPageIndex = index;
      });
    }
  }

  void _forceRefresh(int index) async {
    if (index == 0) {
      RoutingHelper.navigateToMapPage(context);
    } else if (index == 2) {
      RoutingHelper.navigateToListPage(context);
    }
  }

  void ___onItemTapped(int index) {
    if (index == 1) {
      RoutingHelper.navigateToNewJournalPage(context)
          .then((unused) {
        debugPrint("INTERESTED: set state during nav");
        setState(() => {});
      });
    } else {
      setState(() {
        selectedPageIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Travel Notebook'),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
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
              icon: Icon(Icons.add_circle),
              title: Text('Note'),
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



