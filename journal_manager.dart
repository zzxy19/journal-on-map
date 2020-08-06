import 'proto.dart';
import 'journal_metadata_manager.dart';
import 'journal_content_manager.dart';

class JournalManager {
  JournalManager._();
  static final JournalManager manager = JournalManager._();

  final JournalMetadataManager _metadataManager =
      JournalMetadataManager.manager;
  final JournalContentManager _contentManager =
      JournalContentManager.manager;

  insertJournal(Journal journal) async {
  }

  updateJournal(Journal journal) async {
  }

  Future<Journal> getJournal(int journalId) async {
  }

  Future<List<JournalMetadata>> listJournalMetadata() async {
    return _metadataManager.listJournalMetadata();
  }
}