import "proto.dart";

class JournalContentParser {
  JournalContent parsePlainText(String text) {
    List<String> lines = text.split("\n");
    JournalContent content =
        JournalContent(
            lines.map((lineText) => JournalLine.text(lineText)).toList());
    return content;
  }

  String toPlainText(JournalContent content) {
    return content.lines.join("\n");
  }
}