import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'proto.dart';

class JournalContentManager {
  JournalContentManager._();
  static final JournalContentManager manager = JournalContentManager._();
}