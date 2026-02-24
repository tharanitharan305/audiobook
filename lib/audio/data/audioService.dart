import 'dart:async';
import 'package:uuid/uuid.dart';

import 'model.dart';

class MockAudioService implements AudioService {
  final _uuid = const Uuid();

  final Map<String, AudioDocument> _db = {};

  /// ===============================
  /// GET AUDIO BY ID (Fake Network)
  /// ===============================
  @override
  Future<AudioDocument> getAudioById(String id) async {
    await Future.delayed(const Duration(seconds: 1)); // simulate network

    if (_db.containsKey(id)) {
      return _db[id]!;
    }

    // Fake network audio
    final doc = AudioDocument(
      id: id,
      filePath:
      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      title: "Sample Audio $id",
      chapters: [
        AudioChapter(
          id: _uuid.v4(),
          title: "Introduction",
          subtitle: "Getting started",
          startTime: const Duration(seconds: 10),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        AudioChapter(
          id: _uuid.v4(),
          title: "Main Topic",
          subtitle: "Deep dive",
          startTime: const Duration(seconds: 60),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      notes: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _db[id] = doc;
    return doc;
  }

  /// ===============================
  /// ADD CHAPTER
  /// ===============================
  @override
  Future<AudioDocument> addChapter(
      String documentId, AudioChapter chapter) async {
    final doc = _db[documentId]!;

    final updated = doc.copyWith(
      chapters: [...doc.chapters, chapter],
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    _db[documentId] = updated;
    return updated;
  }

  /// ===============================
  /// ADD NOTE
  /// ===============================
  @override
  Future<AudioDocument> addNote(
      String documentId, AudioNote note) async {
    final doc = _db[documentId]!;

    final updated = doc.copyWith(
      notes: [...doc.notes, note],
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    _db[documentId] = updated;
    return updated;
  }

  /// ===============================
  /// UPDATE NOTE
  /// ===============================
  @override
  Future<AudioDocument> updateNote(
      String documentId, AudioNote note) async {
    final doc = _db[documentId]!;

    final updatedNotes = doc.notes
        .map((n) => n.id == note.id ? note : n)
        .toList();

    final updated = doc.copyWith(
      notes: updatedNotes,
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    _db[documentId] = updated;
    return updated;
  }

  /// ===============================
  /// DELETE NOTE (Soft Delete)
  /// ===============================
  @override
  Future<AudioDocument> deleteNote(
      String documentId, String noteId) async {
    final doc = _db[documentId]!;

    final updatedNotes = doc.notes
        .map((n) =>
    n.id == noteId ? n.copyWith(isDeleted: true) : n)
        .toList();

    final updated = doc.copyWith(
      notes: updatedNotes,
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    _db[documentId] = updated;
    return updated;
  }
}
abstract class AudioService {
  Future<AudioDocument> getAudioById(String id);

  Future<AudioDocument> addChapter(
      String documentId,
      AudioChapter chapter,
      );

  Future<AudioDocument> addNote(
      String documentId,
      AudioNote note,
      );

  Future<AudioDocument> updateNote(
      String documentId,
      AudioNote note,
      );

  Future<AudioDocument> deleteNote(
      String documentId,
      String noteId,
      );
}
