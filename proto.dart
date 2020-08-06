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
  Journal(JournalMetadata metadata, JournalContent content) :
        metadata = metadata, content = content;
  JournalMetadata metadata;
  JournalContent content;
}

class JournalContent {
  JournalContent(List<JournalLine> lines) : lines = lines;

  List<JournalLine> lines;

  JournalContent.fromJson(Map<String, dynamic> json)
      : lines = json['lines'];

  Map<String, dynamic> toJson() =>
      {
        'lines': lines,
      };
}

enum JournalLineType {
  TEXT,
}

class JournalLine {
  JournalLineType type;
  String text;

  JournalLine.text(String text) : type = JournalLineType.TEXT, text = text;
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