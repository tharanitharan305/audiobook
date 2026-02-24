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
