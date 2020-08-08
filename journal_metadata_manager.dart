import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'proto.dart';

class JournalMetadataManager {
  static const String _DATABASE_NAME = "Test4Journal.db";

  JournalMetadataManager._();
  static final JournalMetadataManager manager = JournalMetadataManager._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDb();
    return _database;
  }

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _DATABASE_NAME);
    return await openDatabase(
        path,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute(
            "CREATE TABLE JournalMetadata ("
                "id INTEGER PRIMARY KEY,"
                "title TEXT,"
                "longitude REAL,"
                "latitude REAL,"
                "create_time_ms int,"
                "update_time_ms int)"
          );
        });
  }

  insertJournalMetadata(JournalMetadata journalMetadata) async {
    Database db = await database;
    await db.insert("JournalMetadata", journalMetadata.toMap());
  }

  updateJournalMetadata(JournalMetadata journalMetadata) async {
    Database db = await database;
    await db.update("JournalMetadata", journalMetadata.toMap());
  }

  Future<JournalMetadata> getJournalMetadata(int journalId) async {
    Database db = await database;
    List<Map<String, dynamic>> result =
        await db.query("JournalMetadata", where: "id = ?", whereArgs: [journalId]);
    if (result.isEmpty) {
      throw JournalNotFoundException("Journal ID not found in metadata table");
    }
    return JournalMetadata.fromMap(result.elementAt(0));
  }

  Future<List<JournalMetadata>> listJournalMetadata() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query("JournalMetadata");
    if (result.isEmpty) {
      return [];
    }
    return result.map((jsonMap) => JournalMetadata.fromMap(jsonMap)).toList();
  }
}