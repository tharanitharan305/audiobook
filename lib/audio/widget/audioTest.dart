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
  State<AudioChapterScreen> createState() => _AudioChapterScreenState();
}

class _AudioChapterScreenState extends State<AudioChapterScreen> {
  final AudioPlayer player = AudioPlayer();
  final TextEditingController noteController = TextEditingController();

  AudioDocument? document;
  bool loading = true;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await widget.service.getAudioById(widget.documentId);
    await player.setUrl(doc.filePath);

    setState(() {
      document = doc;
      loading = false;
    });
  }

  Future<void> _addNote() async {
    if (document == null) return;

    final position = player.position;

    final note = AudioNote(
      id: const Uuid().v4(),
      content: noteController.text,
      timestamp: position,
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

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [

          Expanded(
            child: Center(
              child: Text(
                document!.title,
                style: theme.textTheme.headlineMedium,
              ),
            ),
          ),

          /// Chapters
          SizedBox(
            height: 120,
            child: ListView.builder(
              itemCount: document!.chapters.length,
              itemBuilder: (context, index) {
                final ch = document!.chapters[index];
                return ListTile(
                  title: Text(ch.title),
                  subtitle: Text(ch.subtitle),
                  onTap: () {
                    player.seek(ch.startTime);
                  },
                );
              },
            ),
          ),

          /// Player Controls
          StreamBuilder<Duration>(
            stream: player.positionStream,
            builder: (context, snapshot) {
              final pos = snapshot.data ?? Duration.zero;
              final total =
                  player.duration ?? const Duration(seconds: 1);

              return Column(
                children: [
                  Slider(
                    value: pos.inSeconds.toDouble(),
                    max: total.inSeconds.toDouble(),
                    onChanged: (value) {
                      player.seek(
                          Duration(seconds: value.toInt()));
                    },
                  ),
                  IconButton(
                    icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      if (isPlaying) {
                        player.pause();
                      } else {
                        player.play();
                      }
                      setState(() {
                        isPlaying = !isPlaying;
                      });
                    },
                  )
                ],
              );
            },
          ),

          /// Notes Section
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.cardColor,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          hintText: "Add note...",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addNote,
                    )
                  ],
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: document!.notes.length,
                    itemBuilder: (context, index) {
                      final note = document!.notes[index];
                      return ListTile(
                        title: Text(note.content),
                        subtitle: Text(
                            note.timestamp.toString()),
                        onTap: () {
                          player.seek(note.timestamp);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}