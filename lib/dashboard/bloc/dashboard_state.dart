import '../data/model.dart';

class DashboardState {}
class DashBoardLoading extends DashboardState{}
class DashBoardLoaded extends DashboardState{
  final List<YourDocument> documents;
  DashBoardLoaded({required this.documents});
}
class DashBoardError extends DashboardState{
  final String message;
  DashBoardError({required this.message});
}
class DashBoardEmpty extends DashboardState{}
