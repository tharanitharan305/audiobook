import 'package:audiobook/dashboard/bloc/dashboard_event.dart';
import 'package:audiobook/dashboard/data/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../audio/data/audioService.dart';
import '../../audio/widget/audioTest.dart';
import '../bloc/dashboard_bloc.dart';

class Doccard extends StatelessWidget {
  final YourDocument doc;

  const Doccard({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: isMobile ? _mobileLayout(theme,context) : _desktopLayout(theme,context),
    );
  }

  // ---------------- MOBILE ----------------

  Widget _mobileLayout(ThemeData theme,context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _topSection(theme),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _actionButtons(theme,context),
        ),
      ],
    );
  }

  // ---------------- DESKTOP ----------------

  Widget _desktopLayout(ThemeData theme,context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _fileIcon(theme),
        const SizedBox(width: 16),
        Expanded(child: _fileDetails(theme)),
        const SizedBox(width: 12),
        ..._actionButtons(theme,context),
      ],
    );
  }

  // ---------------- COMMON SECTIONS ----------------

  Widget _topSection(ThemeData theme) {
    return Row(
      children: [
        _fileIcon(theme),
        const SizedBox(width: 12),
        Expanded(child: _fileDetails(theme)),
      ],
    );
  }

  Widget _fileIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.description,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _fileDetails(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          doc.finalName,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              _formatSize(doc.size),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(width: 10),
            const Icon(Icons.access_time, size: 14),
            const SizedBox(width: 4),
            Text(
              DateFormat.yMMMd().format(doc.dateTime),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _actionButtons(ThemeData theme,context) {
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
          style: TextStyle(color: Colors.green),
        ),
      ),

      OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.menu_book_outlined, size: 18),
        label: const Text("Summarize"),
      ),

      ElevatedButton.icon(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AudioChapterScreen(documentId: doc.id, service: MockAudioService(),),));
        },
        icon: const Icon(Icons.headphones, size: 18),
        label: const Text("Audio Lessons"),
        style: ElevatedButton.styleFrom(
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),

      IconButton(
        onPressed: () {
          context.read<DashboardBloc>().add(DeleteFileFromDashboard(doc: doc));
        },
        icon: const Icon(Icons.delete_outline),
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