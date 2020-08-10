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

  init() async {
    await _metadataManager.initDb();
    await _contentManager.initDirectory();
  }

  insertJournal(Journal journal) async {
    await _contentManager.insertJournalContent(journal);
    await _metadataManager.insertJournalMetadata(journal.metadata);
  }

  updateJournal(Journal journal) async {
    await _contentManager.updateJournalContent(journal);
    await _metadataManager.updateJournalMetadata(journal.metadata);
  }

  Future<Journal> getJournal(String journalId) async {
    Journal journal = Journal();
    Future<JournalContent> journalContent =
        _contentManager.getJournalContent(journalId)
            .then((value) => journal.content = value);
    Future<JournalMetadata> journalMetadata =
        _metadataManager.getJournalMetadata(journalId)
            .then((value) => journal.metadata = value);
    await journalMetadata;
    await journalContent;
    return journal;
  }

  Future<List<JournalMetadata>> listJournalMetadata() async {
    return _metadataManager.listJournalMetadata();
  }
}