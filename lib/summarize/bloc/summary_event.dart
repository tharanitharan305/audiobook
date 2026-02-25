import '../data/model.dart';

class SummaryEvent {

}
class GetSummaryById extends SummaryEvent{
  String id;
  GetSummaryById({required this.id});
}
class SaveSummary extends SummaryEvent{
  Summarize summary;
  SaveSummary({required this.summary});
}
class DeleteSummary extends SummaryEvent{
  String id;
  DeleteSummary({required this.id});
}
class GetSavedSummaries extends SummaryEvent{}