import 'package:audiobook/dashboard/data/model.dart';

class DashboardEvent {
}
class AddFileToDashboard extends DashboardEvent{
  YourDocument doc;
  AddFileToDashboard({required this.doc});
}
class DeleteFileFromDashboard extends DashboardEvent{
  YourDocument doc;
  DeleteFileFromDashboard({required this.doc});
}
class RenameFileInDashboard extends DashboardEvent{
  YourDocument doc;
  RenameFileInDashboard({required this.doc});
}
class MoveFileInDashboard extends DashboardEvent{
  YourDocument doc;
  MoveFileInDashboard({required this.doc});
}
class CopyFileInDashboard extends DashboardEvent{
  YourDocument doc;
  CopyFileInDashboard({required this.doc});
}
class SearchInDashboard extends DashboardEvent{
  String query;
  SearchInDashboard({required this.query});
}
class RefreshDashBoard extends DashboardEvent{

}