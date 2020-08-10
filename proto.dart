import 'package:intl/intl.dart';

class Coordinate {
  Coordinate ({this.latitude, this.longitude});
  final double longitude;
  final double latitude;
}

class Location {
  Location ({this.name, this.coordinate});

  final String name;
  final Coordinate coordinate;
}

// Timestamp class that represents milliseconds since Epoch.
class Timestamp {
  final int _millis;

  Timestamp.fromMillis(int millis) : _millis = millis;

  int millis() => _millis;

  factory Timestamp.current() {
    return Timestamp.fromMillis(DateTime.now().millisecondsSinceEpoch);
  }

  String toString() {
    return DateFormat("yyyy-MM-dd kk:mm a").format(DateTime.fromMillisecondsSinceEpoch(_millis));
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
  JournalMetadata(String id, String title, Location location,
      Timestamp createTime, Timestamp updateTime) {
    this.id = id;
    this.title = title;
    this.location = location;
    this.createTime = createTime;
    this.updateTime = updateTime;
  }
  String id;
  String title;
  Location location;
  Timestamp createTime;
  Timestamp updateTime;

  factory JournalMetadata.fromMap(Map<String, dynamic> json) =>
      new JournalMetadata(
          json["id"],
          json["title"],
          Location(
              name: json["location_name"],
              coordinate:
                  Coordinate(
                      latitude: json["location_lat"],
                      longitude: json["location_lon"])),
          Timestamp.fromMillis(json["create_time_ms"]),
          Timestamp.fromMillis(json["update_time_ms"]));

  Map<String, dynamic> toMap() =>
      {
        "id": id,
        "title": title,
        "location_name": location.name,
        "location_lat": location.coordinate.latitude,
        "location_lon": location.coordinate.longitude,
        "create_time_ms": createTime.millis(),
        "update_time_ms": updateTime.millis(),
      };

  Map<String, dynamic> toMapExcludingId() =>
      {
        "title": title,
        "location_name": location.name,
        "location_lat": location.coordinate.latitude,
        "location_lon": location.coordinate.longitude,
        "create_time_ms": createTime.millis(),
        "update_time_ms": updateTime.millis(),
      };
}

class JournalNotFoundException implements Exception {
  String cause;
  JournalNotFoundException(this.cause);
}