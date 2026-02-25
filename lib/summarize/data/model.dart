
import 'package:audiobook/audio/data/model.dart';

class Summarize {
  final String id;
  final List<Chapter> chapters;

  Summarize({
    required this.id,
    required this.chapters,
  }) ;

  factory Summarize.fromJson(Map<String, dynamic> json) {
    return Summarize(
      id: json['id'],
      chapters: (json['chapters'] as List)
          .map((e) => Chapter.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapters': chapters.map((e) => e.toJson()).toList(),
    };
  }
}

class Chapter {
  final String id;
  final KeyPoints keypoints;
  final String para;
  final String title;
  final String subtitle;
  final double fontSize;
final AudioChapter? audioChapter;
  Chapter({
    required this.audioChapter,
    required this.id,
    required this.keypoints,
    required this.para,
    required this.title,
    required this.subtitle,
    required this.fontSize,
  }) ;

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      audioChapter: AudioChapter.fromJson(json['audioChapter']),
      id: json['id'],
      keypoints: KeyPoints.fromJson(json['keypoints']),
      para: json['para'],
      title: json['title'],
      subtitle: json['subtitle'],
      fontSize: (json['fontSize'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keypoints': keypoints.toJson(),
      'para': para,
      'title': title,
      'subtitle': subtitle,
      'fontSize': fontSize,
      'audioChapter': audioChapter?.toJson() ?? ''
    };
  }
}

class KeyPoints {
  final String id;
  final List<String> points;

  KeyPoints({
    required this.id,
    required this.points,
  }) ;

  factory KeyPoints.fromJson(Map<String, dynamic> json) {
    return KeyPoints(
      id: json['id'],
      points: List<String>.from(json['points']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points,
    };
  }
}