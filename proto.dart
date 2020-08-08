class Coordinate {
  Coordinate (double lon, double lat) : longitude = lon, latitude = lat;

  final double longitude;
  final double latitude;
}

// Timestamp class that represents milliseconds since Epoch.
class Timestamp {
  final int _millis;

  Timestamp.fromMillis(int millis) : _millis = millis;

  int millis() => _millis;

  factory Timestamp.current() {
    return Timestamp.fromMillis(DateTime.now().millisecondsSinceEpoch);
  }
}

class Journal {
  Journal({JournalMetadata metadata, JournalContent content});

  JournalMetadata metadata;
  JournalContent content;
}

class JournalContent {
  JournalContent(List<JournalLine> lines) : lines = lines;

  List<JournalLine> lines;

  factory JournalContent.fromJson(Map<String, dynamic> json) {
    List<dynamic> jsonLines = json['lines'];
    return JournalContent(
        jsonLines.map((jsonLine) => JournalLine.fromJson(jsonLine)).toList());
  }

  Map<String, dynamic> toJson() =>
      {
        'lines': lines,
      };

  String plainText() {
    return lines.map((journalLine) => journalLine.plainText()).join("\n");
  }

  factory JournalContent.fromPlainText(String text) {
    List<String> lines = text.split("\n");
    return JournalContent(
        lines.map((lineText) => JournalLine.text(lineText)).toList());
  }
}

enum JournalLineType {
  TEXT,
}

class JournalLine {
  JournalLineType type;
  String text;

  JournalLine.text(String text) : type = JournalLineType.TEXT, text = text;

  String plainText() {
    return text;
  }

  factory JournalLine.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'TEXT':
        return JournalLine.text(json["line"]);

      default:
        throw Exception("Unexpected type stored in json");
    }
  }

  Map<String, String> toJson() {
    String typeName;
    String line;
    switch (type) {
      case JournalLineType.TEXT:
        typeName = "TEXT";
        line = text;
        break;

      default:
        throw Exception("Unexpected type");
    }
    Map<String, String> jsonMap =
        {
            'type': typeName,
            'line': line,
         };
    return jsonMap;
  }

}

class JournalMetadata {
  JournalMetadata(int id, String title, double longitude, double latitude,
      Timestamp createTime, Timestamp updateTime) {
    this.id = id;
    this.title = title;
    this.location = Coordinate(longitude, latitude);
    this.createTime = createTime;
    this.updateTime = updateTime;
  }
  int id;
  String title;
  Coordinate location;
  Timestamp createTime;
  Timestamp updateTime;

  factory JournalMetadata.fromMap(Map<String, dynamic> json) =>
      new JournalMetadata(
          json["id"],
          json["title"],
          json["longitude"],
          json["latitude"],
          Timestamp.fromMillis(json["create_time_ms"]),
          Timestamp.fromMillis(json["update_time_ms"]));

  Map<String, dynamic> toMap() =>
      {
        "id": id,
        "title": title,
        "longitude": location.longitude,
        "latitude": location.latitude,
        "create_time_ms": createTime.millis(),
        "update_time_ms": updateTime.millis(),
      };
}

class JournalNotFoundException implements Exception {
  String cause;
  JournalNotFoundException(this.cause);
}