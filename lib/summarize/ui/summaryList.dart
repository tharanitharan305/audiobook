import 'package:audiobook/summarize/ui/summaryScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/summary_bloc.dart';
import '../bloc/summary_event.dart';
import '../bloc/summary_state.dart';
import '../data/model.dart';


class SavedSummariesScreen extends StatefulWidget {
  const SavedSummariesScreen({super.key});

  @override
  State<SavedSummariesScreen> createState() =>
      _SavedSummariesScreenState();
}

class _SavedSummariesScreenState
    extends State<SavedSummariesScreen> {

  @override
  void initState() {
    super.initState();
    context.read<SummaryBloc>().add(GetSavedSummaries());
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocBuilder<SummaryBloc, SummaryState>(
        builder: (context, state) {

          if (state is SummaryLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SummaryEmpty) {
            return const Center(
              child: Text(
                "No Saved Summaries",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          if (state is SavedSummariesLoaded) {
            final summaries = state.summaries;

            return isDesktop
                ? _buildGrid(summaries)
                : _buildList(summaries);
          }

          if (state is SummaryError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  /// =========================
  /// Mobile List View
  /// =========================
  Widget _buildList(List<Summarize> summaries) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: summaries.length,
      itemBuilder: (context, index) {
        final summary = summaries[index];

        return GestureDetector(
          onTap: () => _openSummary(summary),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.04),
                  blurRadius: 8,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.chapters.first.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${summary.chapters.length} Chapters",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// =========================
  /// Desktop Grid View
  /// =========================
  Widget _buildGrid(List<Summarize> summaries) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate:
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.4,
      ),
      itemCount: summaries.length,
      itemBuilder: (context, index) {
        final summary = summaries[index];

        return GestureDetector(
          onTap: () => _openSummary(summary),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.chapters.first.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  "${summary.chapters.length} Chapters",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// =========================
  /// Navigation
  /// =========================
  void _openSummary(Summarize summary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SummaryScreen(summary: summary),
      ),
    );
  }
}