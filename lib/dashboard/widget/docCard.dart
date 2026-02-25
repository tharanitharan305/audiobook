import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:audiobook/audio/bloc/audio_bloc.dart';
import 'package:audiobook/audio/bloc/audio_event.dart';
import 'package:audiobook/audio/bloc/audio_state.dart';
import 'package:audiobook/dashboard/bloc/dashboard_bloc.dart';
import 'package:audiobook/dashboard/bloc/dashboard_event.dart';
import 'package:audiobook/dashboard/data/model.dart';
import 'package:audiobook/summarize/data/summary_service.dart';
import 'package:audiobook/summarize/ui/summaryScreen.dart';

class Doccard extends StatelessWidget {
  final YourDocument doc; // Ensure this matches your actual model name

  const Doccard({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Wrap in BlocBuilder so the card actually listens and rebuilds on state changes
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        // Determine the current audio state specific to THIS document
        final isCurrentDoc = state.currentDocument?.id == doc.id;
        final isPlaying = isCurrentDoc && state.isPlaying;

        // We assume global isLoading represents this doc loading if it was just tapped
        // If your state has a specific loadingId, check that here instead.
        final isLoading = state.isLoading && isCurrentDoc;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPlaying
                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlaying
                  ? theme.colorScheme.primary.withOpacity(0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isPlaying
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : theme.shadowColor.withOpacity(0.05),
                blurRadius: isPlaying ? 20 : 12,
                spreadRadius: isPlaying ? 2 : 0,
              ),
            ],
          ),
          child: isMobile
              ? _mobileLayout(theme, context, isCurrentDoc, isPlaying, isLoading)
              : _desktopLayout(theme, context, isCurrentDoc, isPlaying, isLoading),
        );
      },
    );
  }

  // ---------------- MOBILE ----------------

  Widget _mobileLayout(ThemeData theme, BuildContext context, bool isCurrentDoc, bool isPlaying, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _topSection(theme, isPlaying),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: _actionButtons(theme, context, isCurrentDoc, isPlaying, isLoading),
        ),
      ],
    );
  }

  // ---------------- DESKTOP ----------------

  Widget _desktopLayout(ThemeData theme, BuildContext context, bool isCurrentDoc, bool isPlaying, bool isLoading) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _fileIcon(theme, isPlaying),
        const SizedBox(width: 16),
        Expanded(child: _fileDetails(theme)),
        const SizedBox(width: 12),
        ..._actionButtons(theme, context, isCurrentDoc, isPlaying, isLoading),
      ],
    );
  }

  // ---------------- COMMON SECTIONS ----------------

  Widget _topSection(ThemeData theme, bool isPlaying) {
    return Row(
      children: [
        _fileIcon(theme, isPlaying),
        const SizedBox(width: 12),
        Expanded(child: _fileDetails(theme)),
      ],
    );
  }

  Widget _fileIcon(ThemeData theme, bool isPlaying) {
    return BreathingWidget(
      isBreathing: isPlaying,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPlaying
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isPlaying
              ? [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.4), blurRadius: 8)]
              : [],
        ),
        child: Icon(
          isPlaying ? Icons.graphic_eq_rounded : Icons.description_rounded,
          color: isPlaying ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _fileDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          doc.finalName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              _formatSize(doc.size),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.circle, size: 4, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            const SizedBox(width: 8),
            Text(
              DateFormat.yMMMd().format(doc.dateTime),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _actionButtons(
      ThemeData theme,
      BuildContext context,
      bool isCurrentDoc,
      bool isPlaying,
      bool isLoading
      ) {
    return [
      // Ready badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          "Ready",
          style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),

      // Summarize Button
      OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SummaryScreen(summary: SummaryService().getSummaryById("id")),
            ),
          );
        },
        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
        label: const Text("Summarize"),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),

      // Smart Audio Button (Combines Load, Play, and Pause states intelligently)
      ElevatedButton.icon(
        onPressed: isLoading ? null : () {
          if (isCurrentDoc) {
            // If it's already the loaded document, toggle Play/Pause
            context.read<AudioBloc>().add(isPlaying ? PauseAudio() : PlayAudio());
          } else {
            // If it's a new document, trigger a Load event.
            // (Assuming LoadAudio takes the doc ID as a String)
            context.read<AudioBloc>().add(LoadAudio(doc.id));
          }
        },
        icon: isLoading
            ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : Icon(
          isCurrentDoc
              ? (isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded)
              : Icons.headphones_rounded,
          size: 18,
        ),
        label: Text(
          isLoading
              ? "Loading..."
              : (isCurrentDoc
              ? (isPlaying ? "Pause" : "Resume")
              : "Audio Lessons"),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPlaying ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
          foregroundColor: isPlaying ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
          elevation: isPlaying ? 4 : 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Delete Button
      IconButton(
        onPressed: () {
          context.read<DashboardBloc>().add(DeleteFileFromDashboard(doc: doc));
        },
        icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
        tooltip: "Delete Document",
      ),
    ];
  }

  String _formatSize(double bytes) {
    if (bytes < 1024) return "${bytes.toStringAsFixed(0)} B";
    if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    }
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }
}

/// A custom widget that continuously scales its child up and down smoothly when active.
class BreathingWidget extends StatefulWidget {
  final Widget child;
  final bool isBreathing;

  const BreathingWidget({super.key, required this.child, required this.isBreathing});

  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    if (widget.isBreathing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant BreathingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBreathing != oldWidget.isBreathing) {
      if (widget.isBreathing) {
        _controller.repeat(reverse: true);
      } else {
        _controller.animateTo(0.0, duration: const Duration(milliseconds: 300));
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}