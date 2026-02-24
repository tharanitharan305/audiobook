import 'package:audiobook/dashboard/data/model.dart';

class DashboardService {
  List<YourDocument> dbFiles=[];
  Future<List<YourDocument>> getFiles() async {
    return Future.delayed(Duration(seconds: 2),() => dbFiles,);
  }
  Future<void> addFile(YourDocument doc) async {
    dbFiles.add(doc);
  }
  Future<void> deleteFile(YourDocument doc) async {
    dbFiles.remove(doc);
  }
}