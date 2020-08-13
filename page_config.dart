import "proto.dart";
import 'package:flutter/material.dart';
import 'create_journal_page.dart';
import 'home.dart';

class RoutingHelper {
  static Future<void> navigateToListPage(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomePage(HomePageInitialState.listPage())));
  }

  static Future<void> navigateToMapPage(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomePage(HomePageInitialState.mapPage())));
  }

  static Future<bool> navigateToEditJournalPage(BuildContext context, String journalId) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CreateJournalPage(CreateJournalPageInitialState.existingJournal(journalId))));
  }

  static Future<bool> navigateToNewJournalPage(BuildContext context) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CreateJournalPage(CreateJournalPageInitialState.newJournal())));
  }

  static Future<bool> navigateToNewJournalWithLocationPage(BuildContext context, Coordinate coordinate) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CreateJournalPage(CreateJournalPageInitialState.newJournalAt(coordinate))));
  }
}

enum JournalType {
  EDIT_EXISTING,
  NEW,
  NEW_WITH_LOCATION,
}

/// Caller of CreateJournalPage can fill this class to configure a new
/// CreateJournalPage.
class CreateJournalPageInitialState {
  CreateJournalPageInitialState.newJournal() {
    journalType = JournalType.NEW;
  }

  CreateJournalPageInitialState.newJournalAt(Coordinate coordinate) {
    journalType = JournalType.NEW_WITH_LOCATION;
    this.coordinate = coordinate;
  }

  CreateJournalPageInitialState.existingJournal(String journalId) {
    journalType = JournalType.EDIT_EXISTING;
    this.journalId = journalId;
  }

  JournalType journalType;
  String journalId; // EDIT_EXISTING only
  Coordinate coordinate; // NEW_WITH_LOCATION only
}

class HomePageInitialState {
  HomePageInitialState.mapPage() {
    selectedPageIndex = 0;
    this.createJournalPageInitialState = CreateJournalPageInitialState.newJournal();
  }
  HomePageInitialState.listPage() {
    selectedPageIndex = 2;
    this.createJournalPageInitialState = CreateJournalPageInitialState.newJournal();
  }
  HomePageInitialState.newJournalPage() {
    selectedPageIndex = 1;
    this.createJournalPageInitialState = CreateJournalPageInitialState.newJournal();
  }
  HomePageInitialState.editJournalPage(String journalId) {
    selectedPageIndex = 1;
    this.createJournalPageInitialState = CreateJournalPageInitialState.existingJournal(journalId);
  }
  HomePageInitialState.newJournalPageAt(Coordinate coordinate) {
    selectedPageIndex = 1;
    this.createJournalPageInitialState = CreateJournalPageInitialState.newJournalAt(coordinate);
  }

  int selectedPageIndex; // 0:MapPage, 1:CreatePage, 2:ListPage
  CreateJournalPageInitialState createJournalPageInitialState; // CreatePage only
}