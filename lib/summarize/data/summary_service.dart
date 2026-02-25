import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../audio/data/model.dart';
import 'model.dart';



class SummaryService {
  static const String _storageKey = "saved_summaries";
  final _uuid = const Uuid();

  /// ===============================
  /// MOCK NETWORK CALL
  /// ===============================
  Summarize getSummaryById(String id) {


    return Summarize(
      id: id,
      chapters: [
        Chapter(
          title: "Introduction",
          subtitle: "Overview of Topic",
          para:
          "This is a sample paragraph fetched from mock network.",
          fontSize: 16,
          keypoints: KeyPoints(
            points: [
              "Point 1",
              "Point 2",
              "Point 3",
            ], id: '',
          ), id: '',
          audioChapter:    AudioChapter(
            id: _uuid.v4(),
            title: "Introduction",
            subtitle: "Getting started",
            startTime: const Duration(seconds: 10),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),Chapter(
          title: "Introduction",
          subtitle: "Overview of Topic",
          para:
          "This is a sample paragraph fetched from mock network.",
          fontSize: 16,
          keypoints: KeyPoints(
            points: [
              "Point 1",
              "Point 2",
              "Point 3",
            ], id: '',
          ), id: '',  audioChapter:  AudioChapter(
          id: _uuid.v4(),
          title: "Introduction",
          subtitle: "Getting started",
          startTime: const Duration(seconds: 60),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ),Chapter(
          title: "Introduction2",
          subtitle: "Overview of Topic",
          para:
          "This is a sample paragraph fetched from mock network.",
          fontSize: 16,
          keypoints: KeyPoints(
            points: [
              "Point 1",
              "Point 2",
              "Point 3",
            ], id: '',
          ), id: '',  audioChapter: null
        ),Chapter(
          title: "Introduction3",
          subtitle: "Overview of Topic",
          para:
          "This is a sample paragraph fetched from mock network.",
          fontSize: 16,
          keypoints: KeyPoints(
            points: [
              "Point 1",
              "Point 2",
              "Point 3",
            ], id: '',
          ), id: '',  audioChapter: null
        ),Chapter(
          title: "Introduction4",
          subtitle: "Overview of Topic",
          para:
          "This is a sample paragraph fetched from mock network.",
          fontSize: 16,
          keypoints: KeyPoints(
            points: [
              "Point 1",
              "Point 2",
              "Point 3",
            ], id: '',
          ), id: '',  audioChapter: null
        ),Chapter(
          title: "Introduction5",
          subtitle: "Overview of Topic",
          para:
          "This is a sample paragraph fetched from mock network.",
          fontSize: 16,
          keypoints: KeyPoints(
            points: [
              "Point 1",
              "Point 2",
              "Point 3",
            ], id: '',
          ), id: '',  audioChapter: null
        ),Chapter(
          title: "Introduction6",
          subtitle: "Overview of Topic",
          para:
          "This is a sample paragraph fetched from mock network.",
          fontSize: 16,
          keypoints: KeyPoints(
            points: [
              "Point 1",
              "Point 2",
              "Point 3",
            ], id: '',
          ), id: '',  audioChapter: null
        ),Chapter(
          title: "Introduction7",
          subtitle: "Overview of Topic",
          para:
          "This is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.\n\nThis is a sample paragraph fetched from mock network.This is a sample paragraph fetched from mock network.This is a sample paragraph fetched from mock network.This is a sample paragraph fetched from mock network.\nThis is a sample paragraph fetched from mock network.",
          fontSize: 16,
          keypoints: KeyPoints(
            points: [
              "Point 1",
              "Point 2",
              "Point 3",
            ], id: '',
          ), id: '',  audioChapter: null
        ),
      ],
    );
  }

  /// ===============================
  /// SAVE SUMMARY LOCALLY
  /// ===============================
  Future<void> saveSummary(Summarize summary) async {
    final prefs = await SharedPreferences.getInstance();

    final existing = await getAllSavedSummaries();

    // Remove if already exists
    existing.removeWhere((e) => e.id == summary.id);

    existing.add(summary);

    final encoded = jsonEncode(
      existing.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(_storageKey, encoded);
  }

  /// ===============================
  /// GET ALL SAVED SUMMARIES
  /// ===============================
  Future<List<Summarize>> getAllSavedSummaries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);

    if (data == null) return [];

    final List decoded = jsonDecode(data);

    return decoded
        .map((e) => Summarize.fromJson(e))
        .toList();
  }

  /// ===============================
  /// GET SINGLE SAVED SUMMARY BY ID
  /// ===============================
  Future<Summarize?> getSavedSummaryById(String id) async {
    final all = await getAllSavedSummaries();

    try {
      return all.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  /// ===============================
  /// DELETE SUMMARY
  /// ===============================
  Future<void> deleteSummary(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAllSavedSummaries();

    all.removeWhere((e) => e.id == id);

    final encoded =
    jsonEncode(all.map((e) => e.toJson()).toList());

    await prefs.setString(_storageKey, encoded);
  }
}