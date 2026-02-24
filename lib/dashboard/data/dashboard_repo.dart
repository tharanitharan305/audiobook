import 'package:audiobook/dashboard/data/dashboard_service.dart';

import 'model.dart';

class DashboardRepo {
  DashboardService service;
  DashboardRepo({required this.service});
  Future<List<YourDocument>> getFiles() async {
    return service.getFiles();
  }
  Future<void> addFile(YourDocument doc) async {
    service.addFile(doc);
  }
  Future<void> deleteFile(YourDocument doc) async {
    service.deleteFile(doc);
  }

}