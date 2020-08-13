import 'package:flutter/material.dart';

import 'home.dart';
import 'page_config.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journal on a Map',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        accentColor: Colors.cyan,
        dividerColor: Colors.grey,
        backgroundColor: Colors.blueGrey[50],
        cardColor: Colors.blueGrey[50],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(HomePageInitialState.mapPage()),
    );
  }
}
