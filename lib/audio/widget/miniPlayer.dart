import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';
import '../ui/full_player_Screen.dart';

class MiniAudioPlayer extends StatefulWidget {
  /// If true, the player behaves like a Floating Action Button (FAB)
  /// that expands when tapped, and anchors to the right.
  final bool isFloating;

  /// Optional sync function that triggers when the user taps the Sync button
  final VoidCallback? onSync;

  const MiniAudioPlayer({
    super.key,
    this.isFloating = false,
    this.onSync,
  });

  @override
  State<MiniAudioPlayer> createState() => _MiniAudioPlayerState();
}

class _MiniAudioPlayerState extends State<MiniAudioPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    // If floating, start collapsed. Otherwise, always show expanded.
    _isExpanded = !widget.isFloating;

    // Controller for the spinning record animation
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _skip(BuildContext context, Duration currentPos, Duration totalDur, int seconds) {
    final target = currentPos.inSeconds + seconds;
    final safeTarget = target.clamp(0, totalDur.inSeconds);
    context.read<AudioBloc>().add(SeekAudio(Duration(seconds: safeTarget)));
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return BlocConsumer<AudioBloc, AudioState>(
      listenWhen: (previous, current) => previous.isPlaying != current.isPlaying,
      listener: (context, state) {
        if (state.isPlaying) {
          _spinController.repeat(); // Start spinning
        } else {
          _spinController.stop(); // Stop spinning
        }
      },
      builder: (context, state) {
        if (state.currentDocument == null) {
          return const SizedBox.shrink();
        }

        if (state.isPlaying && !_spinController.isAnimating) {
          _spinController.repeat();
        }

        final durationMs = state.duration.inMilliseconds;
        final positionMs = state.position.inMilliseconds;
        final safeDuration = durationMs < 0 ? 0 : durationMs;
        final safePosition = positionMs.clamp(0, safeDuration);
        final progress = safeDuration == 0 ? 0.0 : (safePosition / safeDuration).clamp(0.0, 1.0);

        return LayoutBuilder(
          builder: (context, constraints) {
            // Responsive constraints for Tablet/Web
            double maxWidth = constraints.maxWidth;
            if (maxWidth > 600) maxWidth = 600; // Cap width on large screens

            // Calculate active width based on expanded/floating state
            final activeWidth = _isExpanded
                ? (widget.isFloating ? maxWidth - 32 : maxWidth)
                : 64.0; // FAB size

            return Align(
              // Align bottom-right if floating, bottom-center if standard
              alignment: widget.isFloating ? Alignment.bottomRight : Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.fastLinearToSlowEaseIn,
                margin: widget.isFloating
                    ? const EdgeInsets.only(right: 16, bottom: 16)
                    : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                height: _isExpanded ? 72 : 64,
                width: activeWidth,
                decoration: BoxDecoration(
                  color: color.surface,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: state.isPlaying
                          ? color.primary.withOpacity(0.25)
                          : Colors.black.withOpacity(0.08),
                      blurRadius: state.isPlaying ? 24 : 12,
                      spreadRadius: state.isPlaying ? 4 : 0,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(36),
                  // AnimatedSwitcher handles the fade between the FAB and the full player
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isExpanded
                        ? _buildExpandedPlayer(
                        context, state, color, safeDuration, progress, activeWidth)
                        : _buildCollapsedFAB(color),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ------------------------------------------------------------------
  /// COLLAPSED (FAB) STATE
  /// ------------------------------------------------------------------
  Widget _buildCollapsedFAB(ColorScheme color) {
    return GestureDetector(
      key: const ValueKey('collapsed_fab'),
      onTap: () {
        setState(() => _isExpanded = true);
      },
      child: Container(
        width: 64,
        height: 64,
        color: color.primaryContainer,
        child: Center(
          child: AnimatedBuilder(
            animation: _spinController,
            builder: (_, child) {
              return Transform.rotate(
                angle: _spinController.value * 2 * math.pi,
                child: child,
              );
            },
            child: Icon(
              Icons.music_note_rounded,
              color: color.surface,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  /// ------------------------------------------------------------------
  /// EXPANDED (MINI PLAYER) STATE
  /// ------------------------------------------------------------------
  Widget _buildExpandedPlayer(
      BuildContext context,
      AudioState state,
      ColorScheme color,
      int safeDuration,
      double progress,
      double containerWidth,
      ) {
    // SingleChildScrollView + SizedBox combo prevents RenderFlex overflow
    // errors while the AnimatedContainer's width is expanding/collapsing.
    return SingleChildScrollView(
      key: const ValueKey('expanded_player'),
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: SizedBox(
        width: containerWidth,
        height: 72,
        child: Stack(
          children: [
            /// 1. Interactive Smooth Progress Bar (Bottom Edge)
            Align(
              alignment: Alignment.bottomLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  final dx = details.localPosition.dx.clamp(0.0, containerWidth);
                  final percentage = dx / containerWidth;
                  final seekMs = (safeDuration * percentage).toInt();
                  context.read<AudioBloc>().add(SeekAudio(Duration(milliseconds: seekMs)));
                },
                onTapDown: (details) {
                  final dx = details.localPosition.dx.clamp(0.0, containerWidth);
                  final percentage = dx / containerWidth;
                  final seekMs = (safeDuration * percentage).toInt();
                  context.read<AudioBloc>().add(SeekAudio(Duration(milliseconds: seekMs)));
                },
                child: Container(
                  height: 16, // Tap target area height
                  width: double.infinity,
                  alignment: Alignment.bottomLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.linear,
                    height: 4,
                    width: containerWidth * progress,
                    decoration: BoxDecoration(
                      color: color.primary,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(progress >= 0.98 ? 36 : 4),
                        bottomLeft: const Radius.circular(36),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// 2. Main Content
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FullAudioPlayer()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    /// Spinning Record Icon
                    AnimatedBuilder(
                      animation: _spinController,
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: _spinController.value * 2 * math.pi,
                          child: child,
                        );
                      },
                      child: Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              color.primaryContainer,
                              color.primary.withOpacity(0.8),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                              color: color.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                )
                              ],
                            ),
                            child: Icon(Icons.music_note_rounded, size: 10, color: color.primary),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    /// Title & Subtitle
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.currentDocument!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              state.isPlaying ? "Playing now..." : "Paused",
                              key: ValueKey<bool>(state.isPlaying),
                              style: TextStyle(
                                fontSize: 12,
                                color: color.onSurface.withOpacity(0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// Action Controls Row
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Sync Button (Only if floating & callback exists)
                        if (widget.isFloating && widget.onSync != null)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.sync_rounded,
                              color: color.primary.withOpacity(0.8),
                              size: 24,
                            ),
                            onPressed: widget.onSync,
                          ),
                        if (widget.isFloating && widget.onSync != null)
                          const SizedBox(width: 12),
                        if(!widget.isFloating)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.replay_10_rounded,
                              color: color.onSurface.withOpacity(0.7),
                              size: 26,
                            ),
                            onPressed: () => _skip(context, state.position, state.duration, -10),
                          ),

                        // Play/Pause Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: () {
                              context.read<AudioBloc>().add(
                                state.isPlaying ? PauseAudio() : PlayAudio(),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: state.isPlaying
                                    ? color.primary.withOpacity(0.15)
                                    : Colors.transparent,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) {
                                  return RotationTransition(
                                    turns: Tween<double>(begin: 0.7, end: 1.0).animate(animation),
                                    child: ScaleTransition(scale: animation, child: child),
                                  );
                                },
                                child: Icon(
                                  state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  key: ValueKey<bool>(state.isPlaying),
                                  color: color.primary,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Collapse Button (If floating) or Stop Button (If standard)
                        if (widget.isFloating)
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.chevron_right_rounded,
                              color: color.onSurface.withOpacity(0.6),
                              size: 28,
                            ),
                            onPressed: () {
                              setState(() => _isExpanded = false);
                            },
                          )
                        else
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.forward_10_rounded,
                              color: color.onSurface.withOpacity(0.7),
                              size: 26,
                            ),
                            onPressed: () => _skip(context, state.position, state.duration, 10),
                          ),

                        const SizedBox(width: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}