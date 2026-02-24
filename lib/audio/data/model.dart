import 'dart:io';

/// ===============================
/// AUDIO DOCUMENT
/// ===============================

class AudioDocument {
  final String id;
  final String filePath; // store path instead of File
  final String title;

  final List<AudioChapter> chapters;
  final List<AudioNote> notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  final bool isSynced;
  final bool isDeleted;

  AudioDocument({
    required this.id,
    required this.filePath,
    required this.title,
    required this.chapters,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  });

  File get audioFile => File(filePath);

  AudioDocument copyWith({
    String? id,
    String? filePath,
    String? title,
    List<AudioChapter>? chapters,
    List<AudioNote>? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return AudioDocument(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      chapters: chapters ?? this.chapters,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory AudioDocument.fromJson(Map<String, dynamic> json) {
    return AudioDocument(
      id: json['id'],
      filePath: json['filePath'],
      title: json['title'],
      chapters: (json['chapters'] as List)
          .map((e) => AudioChapter.fromJson(e))
          .toList(),
      notes: (json['notes'] as List)
          .map((e) => AudioNote.fromJson(e))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: json['isSynced'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'title': title,
      'chapters': chapters.map((e) => e.toJson()).toList(),
      'notes': notes.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }
}

/// ===============================
/// AUDIO CHAPTER
/// ===============================

class AudioChapter {
  final String id;
  final String title;
  final String subtitle;

  final Duration startTime;

  final DateTime createdAt;
  final DateTime updatedAt;

  final bool isDeleted;

  AudioChapter({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startTime,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  AudioChapter copyWith({
    String? title,
    String? subtitle,
    Duration? startTime,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return AudioChapter(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      startTime: startTime ?? this.startTime,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory AudioChapter.fromJson(Map<String, dynamic> json) {
    return AudioChapter(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      startTime: Duration(milliseconds: json['startTime']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'startTime': startTime.inMilliseconds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
}

/// ===============================
/// AUDIO NOTE
/// ===============================

class AudioNote {
  final String id;
  final String content;

  final Duration timestamp;

  final DateTime createdAt;
  final DateTime updatedAt;

  final bool isSynced;
  final bool isDeleted;

  AudioNote({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  });

  AudioNote copyWith({
    String? content,
    Duration? timestamp,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return AudioNote(
      id: id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory AudioNote.fromJson(Map<String, dynamic> json) {
    return AudioNote(
      id: json['id'],
      content: json['content'],
      timestamp: Duration(milliseconds: json['timestamp']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isSynced: json['isSynced'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.inMilliseconds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'isDeleted': isDeleted,
    };
  }
}