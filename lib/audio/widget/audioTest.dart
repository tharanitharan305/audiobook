import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:uuid/uuid.dart';

import '../data/audioService.dart';
import '../data/model.dart';

class AudioChapterScreen extends StatefulWidget {
  final String documentId;
  final AudioService service;

  const AudioChapterScreen({
    super.key,
    required this.documentId,
    required this.service,
  });

  @override
  State<AudioChapterScreen> createState() =>
      _AudioChapterScreenState();
}

class _AudioChapterScreenState
    extends State<AudioChapterScreen> {
  final AudioPlayer player = AudioPlayer();
  final TextEditingController noteController =
  TextEditingController();

  AudioDocument? document;
  bool loading = true;
  bool isPlaying = false;
  double speed = 1.0;

  int selectedTab = 0; // 0 = Notes, 1 = Short Notes

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc =
    await widget.service.getAudioById(widget.documentId);
    await player.setUrl(doc.filePath);

    setState(() {
      document = doc;
      loading = false;
    });
  }

  Future<void> _addNote() async {
    if (noteController.text.trim().isEmpty) return;

    final note = AudioNote(
      id: const Uuid().v4(),
      content: noteController.text.trim(),
      timestamp: player.position,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final updated =
    await widget.service.addNote(document!.id, note);

    setState(() {
      document = updated;
      noteController.clear();
    });
  }

  String format(Duration d) {
    return "${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    if (loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final reversedNotes =
    document!.notes.reversed.toList();

    return Scaffold(
      backgroundColor: color.background,

      body: Column(
        children: [

          /// ================= PLAYER =================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: StreamBuilder<Duration>(
                stream: player.positionStream,
                builder: (context, snapshot) {
                  final pos = snapshot.data ?? Duration.zero;
                  final total =
                      player.duration ?? const Duration(seconds: 1);

                  final progress = total.inMilliseconds == 0
                      ? 0.0
                      : pos.inMilliseconds /
                      total.inMilliseconds;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      /// Play Button
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.primary,
                        ),
                        child: IconButton(
                          iconSize: 40,
                          icon: Icon(
                            isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (isPlaying) {
                              player.pause();
                            } else {
                              player.play();
                            }
                            setState(() =>
                            isPlaying = !isPlaying);
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// Progress Bar
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape:
                          const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: progress,
                          onChanged: (value) {
                            player.seek(Duration(
                                milliseconds:
                                (total.inMilliseconds *
                                    value)
                                    .toInt()));
                          },
                        ),
                      ),

                      /// Time + Speed Row
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(format(pos)),
                          _speedSelector(),
                          Text(format(total - pos)),
                        ],
                      )
                    ],
                  );
                },
              ),
            ),
          ),

          /// ================= BOTTOM PANEL =================
          Container(
            height: 300,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.surfaceVariant,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [

                /// Segmented Switch
                _segmentedControl(),

                const SizedBox(height: 16),

                /// Dynamic Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration:
                    const Duration(milliseconds: 250),
                    child: selectedTab == 0
                        ? _chaptersView()
                        : _notesView(),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget _speedSelector() {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color:
            Theme.of(context).colorScheme.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double>(
          value: speed,
          items: [1.0, 1.5, 2.0]
              .map(
                (s) => DropdownMenuItem(
              value: s,
              child: Text("${s}x"),
            ),
          )
              .toList(),
          onChanged: (value) {
            setState(() => speed = value!);
            player.setSpeed(value!);
          },
        ),
      ),
    );
  }
  Widget _segmentedControl() {
    final color = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _segmentItem("Chapters", 0),
          _segmentItem("Notes", 1),
        ],
      ),
    );
  }

  Widget _segmentItem(String title, int index) {
    final isSelected = selectedTab == index;
    final color = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () =>
            setState(() => selectedTab = index),
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 200),
          padding:
          const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? color.primary
                : Colors.transparent,
            borderRadius:
            BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : color.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _chaptersView() {
    return ListView.builder(
      itemCount: document!.chapters.length,
      itemBuilder: (context, index) {
        final ch = document!.chapters[index];
        return Card(
          child: ListTile(
            title: Text(ch.title),
            subtitle: Text(ch.subtitle),
            onTap: () {
              player.seek(ch.startTime);
            },
          ),
        );
      },
    );
  }
  Widget _notesView() {
    final reversed =
    document!.notes.reversed.toList();

    return Column(
      children: [

        /// Add Note
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: noteController,
                decoration:
                const InputDecoration(
                  hintText: "Write a note...",
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send,
                  color: Theme.of(context)
                      .colorScheme
                      .primary),
              onPressed: _addNote,
            )
          ],
        ),

        const SizedBox(height: 10),

        Expanded(
          child: ListView.builder(
            itemCount: reversed.length,
            itemBuilder: (context, index) {
              final note = reversed[index];
              return Card(
                child: ListTile(
                  title: Text(note.content),
                  subtitle:
                  Text(format(note.timestamp)),
                  onTap: () =>
                      player.seek(note.timestamp),
                ),
              );
            },
          ),
        )
      ],
    );
  }

}