import 'package:audiobook/audio/bloc/audio_bloc.dart';
import 'package:audiobook/audio/bloc/audio_event.dart';
import 'package:audiobook/audio/widget/miniPlayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/model.dart';
import '../bloc/summary_bloc.dart';
import '../bloc/summary_event.dart';
import '../bloc/summary_state.dart';

class SummaryScreen extends StatefulWidget {
  final Summarize summary;

  const SummaryScreen({super.key, required this.summary});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  int selectedIndex = 0;
  bool isSaved = false;
bool? sync(BuildContext context){
  if(widget.summary.chapters[selectedIndex].audioChapter!=null) {
    context.read<AudioBloc>().add(SeekAudio(widget.summary.chapters[selectedIndex].audioChapter!.startTime));
    return true;
  }
  return null;
}
  @override
  Widget build(BuildContext context) {
    final chapter = widget.summary.chapters[selectedIndex];
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<SummaryBloc, SummaryState>(
      listener: (context, state) {
        if (state is SummaryLoaded) {
          setState(() => isSaved = true);
          _showSnack("Summary Saved Successfully");
        }

        if (state is SummaryEmpty) {
          setState(() => isSaved = false);
          _showSnack("Summary Deleted");
        }

        if (state is SummaryError) {
          _showSnack(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.background,
        floatingActionButton: MiniAudioPlayer(isFloating: true,onSync: (){
          sync(context);
        },),
        appBar: isDesktop
            ? null
            : AppBar(
          elevation: 0,
          backgroundColor: colorScheme.surface,
          title: Text(
            chapter.title,
            style: TextStyle(color: colorScheme.onSurface),
          ),
          iconTheme: IconThemeData(color: colorScheme.onSurface),
          actions: [

            IconButton(
              icon: Icon(
                isSaved
                    ? Icons.menu_book_outlined
                    : Icons.menu_book_rounded,
                color: colorScheme.primary,
              ),
              onPressed: _openChapterDrawer,
            ), IconButton(
              icon: Icon(
                isSaved
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                color: colorScheme.primary,
              ),
              onPressed: _handleSaveDelete,
            ),
          ],
        ),
        body: SafeArea(
          child: isDesktop
              ? Row(
            children: [
              _buildChapterPanel(colorScheme),
              Expanded(
                child: Stack(
                  children: [
                    _buildContent(chapter, colorScheme),

                    Positioned(
                      top: 20,
                      right: 20,
                      child: IconButton(
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          size: 28,
                          color: colorScheme.primary,
                        ),
                        onPressed: _handleSaveDelete,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
              : _buildMobileLayout(chapter, colorScheme),
        ),
      ),
    );
  }

  void _handleSaveDelete() {
    final bloc = context.read<SummaryBloc>();

    if (isSaved) {
      bloc.add(DeleteSummary(id: widget.summary.id));
    } else {
      bloc.add(SaveSummary(summary: widget.summary));
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
  void _openChapterDrawer() {
    final colorScheme = Theme.of(context).colorScheme;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Chapters",
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
              height: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                  )
                ],
              ),
              child: SafeArea(
                child: _buildChapterPanel(colorScheme),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, _, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// =========================
  /// Desktop Chapter Panel
  /// =========================
  Widget _buildChapterPanel(ColorScheme colorScheme) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(color: colorScheme.outline),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Chapters",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: widget.summary.chapters.length,
              itemBuilder: (context, index) {
                final chapter = widget.summary.chapters[index];
                final isSelected = selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedIndex = index);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.secondaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Chapter ${index + 1}",
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chapter.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? colorScheme.onSecondaryContainer
                                : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// Content Area
  /// =========================
  Widget _buildContent(
      Chapter chapter, ColorScheme colorScheme) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 24),
              Text(
                "Chapter ${selectedIndex + 1}",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                chapter.title,
                style: TextStyle(
                  fontSize: 40,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                chapter.para,
                style: TextStyle(
                  fontSize: chapter.fontSize,
                  height: 1.8,
                  color: colorScheme.onBackground
                      .withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 40),
              _buildKeyPoints(chapter.keypoints, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  /// =========================
  /// Key Points Card
  /// =========================
  Widget _buildKeyPoints(
      KeyPoints keyPoints, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: BoxBorder.all(color: colorScheme.primary)
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  size: 20,
                  color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                "Key Points",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...keyPoints.points.map(
                (point) => Padding(
              padding:
              const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    "• ",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 18,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color:
                        colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
      Chapter chapter, ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: colorScheme.background,
      drawer: Drawer(
        backgroundColor: colorScheme.surface,
        child: _buildChapterPanel(colorScheme),
      ),
      body: _buildContent(chapter, colorScheme),
    );
  }
}