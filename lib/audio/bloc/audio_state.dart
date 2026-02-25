
import '../data/model.dart';

class AudioState {
  final bool isLoading;

  final AudioDocument? currentDocument;

  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double speed;

  final bool showMiniPlayer;

  const AudioState({
    this.isLoading = false,
    this.currentDocument,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.showMiniPlayer = false,
  });

  AudioState copyWith({
    bool? isLoading,
    AudioDocument? currentDocument,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? speed,
    bool? showMiniPlayer,
  }) {
    return AudioState(
      isLoading: isLoading ?? this.isLoading,
      currentDocument: currentDocument ?? this.currentDocument,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      showMiniPlayer: showMiniPlayer ?? this.showMiniPlayer,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    currentDocument,
    isPlaying,
    position,
    duration,
    speed,
    showMiniPlayer,
  ];
}