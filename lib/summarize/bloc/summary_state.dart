import 'package:audiobook/summarize/data/model.dart';

class SummaryState {}
class SummaryLoading extends SummaryState{}
class SummaryLoaded extends SummaryState{
final Summarize summary;
SummaryLoaded({required this.summary});
}
class SummaryError extends SummaryState{
  final String message;
  SummaryError({required this.message});
}
class SummaryEmpty extends SummaryState{}
class SavedSummariesLoaded extends SummaryState{
  List<Summarize> summaries;
SavedSummariesLoaded({required this.summaries});

}