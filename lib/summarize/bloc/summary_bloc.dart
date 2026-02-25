import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/model.dart';
import '../data/summary_service.dart';
import 'summary_event.dart';
import 'summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final SummaryService service;

  SummaryBloc({required this.service}) : super(SummaryEmpty()) {

    /// ==============================
    /// GET SUMMARY BY ID (Network)
    /// ==============================
    on<GetSummaryById>((event, emit) async {
      emit(SummaryLoading());
      try {
        final summary = await service.getSummaryById(event.id);
        emit(SummaryLoaded(summary: summary));
      } catch (e) {
        emit(SummaryError(message: e.toString()));
      }
    });

    /// ==============================
    /// SAVE SUMMARY
    /// ==============================
    on<SaveSummary>((event, emit) async {
      try {
        await service.saveSummary(event.summary);
        emit(SummaryLoaded(summary: event.summary));
      } catch (e) {
        emit(SummaryError(message: e.toString()));
      }
    });

    /// ==============================
    /// DELETE SUMMARY
    /// ==============================
    on<DeleteSummary>((event, emit) async {
      try {
        await service.deleteSummary(event.id);
        emit(SummaryEmpty());
      } catch (e) {
        emit(SummaryError(message: e.toString()));
      }
    });

    /// ==============================
    /// GET ALL SAVED SUMMARIES
    /// ==============================
    on<GetSavedSummaries>((event, emit) async {
      emit(SummaryLoading());
      try {
        final summaries = await service.getAllSavedSummaries();

        if (summaries.isEmpty) {
          emit(SummaryEmpty());
        } else {
          // You only have SummaryLoaded with single summary
          // For now returning first summary
          emit(SavedSummariesLoaded(summaries: summaries));
        }
      } catch (e) {
        emit(SummaryError(message: e.toString()));
      }
    });
  }
}