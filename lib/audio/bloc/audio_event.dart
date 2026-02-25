
import '../data/model.dart';


abstract class AudioEvent {
  const AudioEvent();

  @override
  List<Object?> get props => [];
}

/// ===============================
/// LOAD DOCUMENT + AUDIO
/// ===============================
class LoadAudio extends AudioEvent {
  final String documentId;

  const LoadAudio(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

/// ===============================
/// PLAY / PAUSE
/// ===============================
class PlayAudio extends AudioEvent {}

class PauseAudio extends AudioEvent {}

class StopAudio extends AudioEvent {}

/// ===============================
/// SEEK
/// ===============================
class SeekAudio extends AudioEvent {
  final Duration position;

  const SeekAudio(this.position);

  @override
  List<Object?> get props => [position];
}

/// ===============================
/// SPEED
/// ===============================
class ChangeSpeed extends AudioEvent {
  final double speed;

  const ChangeSpeed(this.speed);

  @override
  List<Object?> get props => [speed];
}

/// ===============================
/// CHAPTER JUMP
/// ===============================
class JumpToChapter extends AudioEvent {
  final AudioChapter chapter;

  const JumpToChapter(this.chapter);

  @override
  List<Object?> get props => [chapter];
}

/// ===============================
/// NOTES
/// ===============================
class AddNoteEvent extends AudioEvent {
  final AudioNote note;

  const AddNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class UpdateNoteEvent extends AudioEvent {
  final AudioNote note;

  const UpdateNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

class DeleteNoteEvent extends AudioEvent {
  final String noteId;

  const DeleteNoteEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// ===============================
/// INTERNAL STREAM UPDATES
/// (from AudioEngineService)
/// ===============================
class PositionChanged extends AudioEvent {
  final Duration position;

  const PositionChanged(this.position);

  @override
  List<Object?> get props => [position];
}

class DurationChanged extends AudioEvent {
  final Duration duration;

  const DurationChanged(this.duration);

  @override
  List<Object?> get props => [duration];
}

class PlayingStatusChanged extends AudioEvent {
  final bool isPlaying;

  const PlayingStatusChanged(this.isPlaying);

  @override
  List<Object?> get props => [isPlaying];
}