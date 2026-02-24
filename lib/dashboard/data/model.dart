import 'dart:io';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class YourDocument {
  final String id;
  final File file;
  final String finalName;
  final String dateTime;

  YourDocument({
    String? id,
    required this.file,
    required this.finalName,
    required this.dateTime,
  }) : id = id ?? uuid.v4();
}