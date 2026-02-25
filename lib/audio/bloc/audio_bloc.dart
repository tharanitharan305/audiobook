import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/audioService.dart';
import 'audio_event.dart';
import 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioService documentService;
  final AudioEngineService engine;

  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playingSub;

  AudioBloc({
    required this.documentService,
    required this.engine,
  }) : super(const AudioState()) {

    /// ===============================
    /// ENGINE STREAM LISTENERS
    /// ===============================
    _positionSub = engine.positionStream.listen(
          (pos) => add(PositionChanged(pos)),
    );

    _durationSub = engine.durationStream.listen(
          (dur) => add(DurationChanged(dur)),
    );

    _playingSub = engine.isPlayingStream.listen(
          (playing) => add(PlayingStatusChanged(playing)),
    );

    /// ===============================
    /// EVENT HANDLERS
    /// ===============================
    on<LoadAudio>(_onLoadAudio);
    on<PlayAudio>(_onPlay);
    on<PauseAudio>(_onPause);
    on<StopAudio>(_onStop);
    on<SeekAudio>(_onSeek);
    on<ChangeSpeed>(_onChangeSpeed);
    on<JumpToChapter>(_onJumpToChapter);

    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);

    on<PositionChanged>(_onPositionChanged);
    on<DurationChanged>(_onDurationChanged);
    on<PlayingStatusChanged>(_onPlayingChanged);
  }

  /// =====================================================
  /// LOAD AUDIO + DOCUMENT
  /// =====================================================
  Future<void> _onLoadAudio(
      LoadAudio event, Emitter<AudioState> emit) async {

    emit(state.copyWith(isLoading: true));

    final doc = await documentService.getAudioById(event.documentId);

    await engine.load(doc.filePath);

    emit(state.copyWith(
      isLoading: false,
      currentDocument: doc,
      showMiniPlayer: true,
      position: Duration.zero,
      duration: Duration.zero,
    ));
  }

  /// =====================================================
  /// PLAY
  /// =====================================================
  Future<void> _onPlay(
      PlayAudio event, Emitter<AudioState> emit) async {
    await engine.play();
  }

  /// =====================================================
  /// PAUSE
  /// =====================================================
  Future<void> _onPause(
      PauseAudio event, Emitter<AudioState> emit) async {
    await engine.pause();
  }

  /// =====================================================
  /// STOP
  /// =====================================================
  Future<void> _onStop(
      StopAudio event, Emitter<AudioState> emit) async {
    await engine.stop();

    emit(state.copyWith(
      isPlaying: false,
      position: Duration.zero,
      showMiniPlayer: false,
      currentDocument: null,
    ));
  }

  /// =====================================================
  /// SEEK
  /// =====================================================
  Future<void> _onSeek(
      SeekAudio event, Emitter<AudioState> emit) async {
    await engine.seek(event.position);
  }

  /// =====================================================
  /// SPEED
  /// =====================================================
  Future<void> _onChangeSpeed(
      ChangeSpeed event, Emitter<AudioState> emit) async {
    await engine.setSpeed(event.speed);

    emit(state.copyWith(speed: event.speed));
  }

  /// =====================================================
  /// JUMP TO CHAPTER
  /// =====================================================
  Future<void> _onJumpToChapter(
      JumpToChapter event, Emitter<AudioState> emit) async {
    await engine.seek(event.chapter.startTime);
  }

  /// =====================================================
  /// NOTES
  /// =====================================================
  Future<void> _onAddNote(
      AddNoteEvent event, Emitter<AudioState> emit) async {

    if (state.currentDocument == null) return;

    final updated = await documentService.addNote(
      state.currentDocument!.id,
      event.note,
    );

    emit(state.copyWith(currentDocument: updated));
  }

  Future<void> _onUpdateNote(
      UpdateNoteEvent event, Emitter<AudioState> emit) async {

    if (state.currentDocument == null) return;

    final updated = await documentService.updateNote(
      state.currentDocument!.id,
      event.note,
    );

    emit(state.copyWith(currentDocument: updated));
  }

  Future<void> _onDeleteNote(
      DeleteNoteEvent event, Emitter<AudioState> emit) async {

    if (state.currentDocument == null) return;

    final updated = await documentService.deleteNote(
      state.currentDocument!.id,
      event.noteId,
    );

    emit(state.copyWith(currentDocument: updated));
  }

  /// =====================================================
  /// INTERNAL STREAM EVENTS
  /// =====================================================
  void _onPositionChanged(
      PositionChanged event, Emitter<AudioState> emit) {
    emit(state.copyWith(position: event.position));
  }

  void _onDurationChanged(
      DurationChanged event, Emitter<AudioState> emit) {
    print("DURATION RECEIVED: ${event.duration}");
    emit(state.copyWith(duration: event.duration));
  }

  void _onPlayingChanged(
      PlayingStatusChanged event, Emitter<AudioState> emit) {
    emit(state.copyWith(isPlaying: event.isPlaying));
  }

  /// =====================================================
  /// DISPOSE
  /// =====================================================
  @override
  Future<void> close() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playingSub?.cancel();
    engine.dispose();
    return super.close();
  }
}