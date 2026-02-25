import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';
import '../data/model.dart'; // Make sure this path matches your project structure

class FullAudioPlayer extends StatefulWidget {
  const FullAudioPlayer({super.key});

  @override
  State<FullAudioPlayer> createState() => _FullAudioPlayerState();
}

class _FullAudioPlayerState extends State<FullAudioPlayer> {
  int selectedTab = 0;
  final TextEditingController noteController = TextEditingController();

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _skip(BuildContext context, Duration currentPos, Duration totalDur, int seconds) {
    final target = currentPos.inSeconds + seconds;
    final safeTarget = target.clamp(0, totalDur.inSeconds);
    context.read<AudioBloc>().add(SeekAudio(Duration(seconds: safeTarget)));
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.surface,
              color.surfaceContainerHighest.withOpacity(0.4),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<AudioBloc, AudioState>(
            builder: (context, state) {
              if (state.currentDocument == null) {
                return const Center(
                  child: Text("No Audio Loaded", style: TextStyle(fontSize: 18)),
                );
              }

              final durationMs = state.duration.inMilliseconds;
              final positionMs = state.position.inMilliseconds;

              final safeDuration = durationMs < 0 ? 0 : durationMs;
              final safePosition = positionMs.clamp(0, safeDuration);
              final progress = safeDuration == 0 ? 0.0 : (safePosition / safeDuration).clamp(0.0, 1.0);

              return Column(
                children: [
                  /// TOP BAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                          onPressed:(){
                            Navigator.canPop(context);
                          },
                        ),
                        const Text(
                          "Now Playing",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 14,
                          ),
                        ),
                        // Placeholder to balance the row symmetrically
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  /// HERO / ALBUM ART (Responsive Squircle)
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: AnimatedScale(
                        scale: state.isPlaying ? 1.0 : 0.9,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            margin: EdgeInsets.all(size.width * 0.12), // Responsive margin
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(36),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color.primaryContainer,
                                  color.primary.withOpacity(0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: state.isPlaying
                                      ? color.primary.withOpacity(0.4)
                                      : Colors.black.withOpacity(0.1),
                                  blurRadius: state.isPlaying ? 30 : 15,
                                  spreadRadius: state.isPlaying ? 8 : 0,
                                  offset: const Offset(0, 15),
                                )
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.auto_stories_rounded, // Better suited for documents
                                size: 80,
                                color: color.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// TITLE & AUTHOR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          state.currentDocument!.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Document Reader", // Placeholder for author or doc type
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: color.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// SLIDER & TIMESTAMPS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4,
                            activeTrackColor: color.primary,
                            inactiveTrackColor: color.outlineVariant.withOpacity(0.4),
                            thumbColor: color.primary,
                            overlayColor: color.primary.withOpacity(0.15),
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                            trackShape: const RoundedRectSliderTrackShape(),
                          ),
                          child: Slider(
                            value: progress,
                            onChanged: safeDuration == 0
                                ? null
                                : (value) {
                              final seekPosition = Duration(
                                milliseconds: (safeDuration * value).toInt(),
                              );
                              context.read<AudioBloc>().add(SeekAudio(seekPosition));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _format(Duration(milliseconds: safePosition)),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: color.onSurface.withOpacity(0.7),
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                              Text(
                                _format(Duration(milliseconds: safeDuration)),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: color.onSurface.withOpacity(0.7),
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// MAIN CONTROLS ROW
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Left: Speed Selector
                        _speedSelector(state, color),

                        // Center: Playback Controls
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              iconSize: 36,
                              icon: const Icon(Icons.replay_10_rounded),
                              color: color.onSurface.withOpacity(0.8),
                              onPressed: () => _skip(context, state.position, state.duration, -10),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                context.read<AudioBloc>().add(
                                  state.isPlaying ? PauseAudio() : PlayAudio(),
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color.primary,
                                  boxShadow: [
                                    if (state.isPlaying)
                                      BoxShadow(
                                        color: color.primary.withOpacity(0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      )
                                  ],
                                ),
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    transitionBuilder: (child, animation) {
                                      return ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      );
                                    },
                                    child: Icon(
                                      state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                      key: ValueKey<bool>(state.isPlaying),
                                      color: color.onPrimary,
                                      size: 38,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              iconSize: 36,
                              icon: const Icon(Icons.forward_10_rounded),
                              color: color.onSurface.withOpacity(0.8),
                              onPressed: () => _skip(context, state.position, state.duration, 10),
                            ),
                          ],
                        ),

                        // Right: Add Bookmark/Note Shortcut
                        IconButton(
                          iconSize: 28,
                          icon: const Icon(Icons.bookmark_add_outlined),
                          color: color.onSurface.withOpacity(0.6),
                          onPressed: () {
                            setState(() => selectedTab = 1); // Switch to notes tab
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// TABS
                  _segmentedControl(color),

                  const SizedBox(height: 16),

                  /// CONTENT (Chapters / Notes)
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: color.surface,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          )
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: selectedTab == 0
                            ? _chaptersView(state, color)
                            : _notesView(state, color),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _speedSelector(AudioState state, ColorScheme color) {
    return PopupMenuButton<double>(
      initialValue: state.speed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.surfaceContainerHighest,
      onSelected: (value) {
        context.read<AudioBloc>().add(ChangeSpeed(value));
      },
      itemBuilder: (context) => [1.0, 1.25, 1.5, 2.0].map((s) {
        return PopupMenuItem(
          value: s,
          child: Text(
            "${s}x",
            style: TextStyle(
              fontWeight: state.speed == s ? FontWeight.bold : FontWeight.normal,
              color: state.speed == s ? color.primary : color.onSurface,
            ),
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "${state.speed}x",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color.primary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _segmentedControl(ColorScheme color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _segmentItem("Chapters", 0, color),
            _segmentItem("Notes", 1, color),
          ],
        ),
      ),
    );
  }

  Widget _segmentItem(String title, int index, ColorScheme color) {
    final isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? color.primary : color.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chaptersView(AudioState state, ColorScheme color) {
    final chapters = state.currentDocument?.chapters ?? [];

    if (chapters.isEmpty) {
      return Center(
        child: Text(
          "No chapters available",
          style: TextStyle(color: color.onSurface.withOpacity(0.5)),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: chapters.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ch = chapters[index];
        final isCurrent = state.position >= ch.startTime &&
            (index == chapters.length - 1 || state.position < chapters[index + 1].startTime);

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.read<AudioBloc>().add(JumpToChapter(ch));
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrent ? color.primary.withOpacity(0.08) : color.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent ? color.primary.withOpacity(0.3) : color.outlineVariant.withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCurrent ? color.primary : color.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCurrent ? Icons.volume_up_rounded : Icons.menu_book_rounded,
                    color: isCurrent ? color.onPrimary : color.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ch.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? color.primary : color.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ch.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: color.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _format(ch.startTime),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCurrent ? color.primary : color.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _notesView(AudioState state, ColorScheme color) {
    final notes = state.currentDocument?.notes
        .where((n) => !n.isDeleted)
        .toList()
        .reversed
        .toList() ?? [];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          /// ADD NOTE FIELD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      hintText: "Add a note at this timestamp...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send_rounded, color: color.primary),
                  onPressed: () {
                    if (noteController.text.trim().isEmpty) return;

                    final note = AudioNote(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      content: noteController.text.trim(),
                      timestamp: state.position,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    context.read<AudioBloc>().add(AddNoteEvent(note));
                    noteController.clear();
                    FocusScope.of(context).unfocus(); // Dismiss keyboard
                  },
                )
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// NOTES LIST
          Expanded(
            child: notes.isEmpty
                ? Center(
              child: Text(
                "No notes added yet.",
                style: TextStyle(color: color.onSurface.withOpacity(0.5)),
              ),
            )
                : ListView.separated(
              itemCount: notes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final note = notes[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    context.read<AudioBloc>().add(SeekAudio(note.timestamp));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.outlineVariant.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time_filled_rounded, size: 16, color: color.primary),
                            const SizedBox(width: 6),
                            Text(
                              _format(note.timestamp),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: color.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          note.content,
                          style: TextStyle(
                            color: color.onSurface.withOpacity(0.85),
                            height: 1.5,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}