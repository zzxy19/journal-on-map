import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'proto.dart';

class JournalContentManager {
  JournalContentManager._();
  static final JournalContentManager manager = JournalContentManager._();

  static const String _JOURNAL_DIR_NAME = "journals";
  static const String _JOURNAL_INDEX_FILE = "index";

  static Directory _journalDir;

  Future<Directory> get journalDirectory async {
    if (_journalDir != null) {
      return _journalDir;
    }

    _journalDir = await initDirectory();
    return _journalDir;
  }

  initDirectory() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    String journalDirectoryPath = join(appDirectory.path, _JOURNAL_DIR_NAME);
    Directory dir = Directory(journalDirectoryPath);
    bool dirExists = await dir.exists();
    if (!dirExists) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  _writeToFile(Journal journal) async {
    Directory journalDir = await journalDirectory;
    Directory fileDir = Directory(join(journalDir.path, journal.metadata.id));
    await fileDir.create();
    String fileName = join(fileDir.path, _JOURNAL_INDEX_FILE);
    File file = File(fileName);
    await file.writeAsString(jsonEncode(journal.content.toJson()));
  }

  insertJournalContent(Journal journal) async {
    await _writeToFile(journal);
  }

  updateJournalContent(Journal journal) async {
    await _writeToFile(journal);
  }

  Future<JournalContent> getJournalContent(String journalId) async {
    Directory journalDir = await journalDirectory;
    String fileName = join(journalDir.path, journalId, _JOURNAL_INDEX_FILE);
    File file = File(fileName);
    bool fileExists = await file.exists();
    if (!fileExists) {
      throw JournalNotFoundException("Journal file not found on disk");
    }
    String bytesRead = await file.readAsString();
    return JournalContent.fromJson(jsonDecode(bytesRead));
  }
}