import 'dart:async';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';
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


class AudioEngineService {
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playerStateSub;

  /// ==========================
  /// Streams Exposed to BLoC
  /// ==========================
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _isPlayingController = StreamController<bool>.broadcast();

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<bool> get isPlayingStream => _isPlayingController.stream;

  /// ==========================
  /// INIT LISTENERS
  /// ==========================
  void init() {
    _positionSub = _player.positionStream.listen((pos) {
      _positionController.add(pos);
    });

    _durationSub = _player.durationStream.listen((dur) {
      _durationController.add(dur ?? Duration.zero);
    });

    _playerStateSub = _player.playerStateStream.listen((state) {
      _isPlayingController.add(state.playing);
    });
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.ready) {
        final dur = _player.duration;
        if (dur != null) {
          _durationController.add(dur);
        }
      }
    });
  }

  /// ==========================
  /// LOAD AUDIO
  /// ==========================
  Future<void> load(String url) async {
    await _player.setUrl(url);
    final duration = _player.duration;
    if (duration != null) {
      _durationController.add(duration);
    }
  }

  /// ==========================
  /// PLAY
  /// ==========================
  Future<void> play() async {
    await _player.play();
  }

  /// ==========================
  /// PAUSE
  /// ==========================
  Future<void> pause() async {
    await _player.pause();
  }

  /// ==========================
  /// SEEK
  /// ==========================
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// ==========================
  /// SPEED
  /// ==========================
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  /// ==========================
  /// STOP
  /// ==========================
  Future<void> stop() async {
    await _player.stop();
  }

  /// ==========================
  /// GET CURRENT VALUES
  /// ==========================
  Duration get currentPosition => _player.position;
  Duration? get currentDuration => _player.duration;
  bool get isPlaying => _player.playing;

  /// ==========================
  /// DISPOSE
  /// ==========================
  Future<void> dispose() async {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _playerStateSub?.cancel();

    await _positionController.close();
    await _durationController.close();
    await _isPlayingController.close();

    await _player.dispose();
  }
}