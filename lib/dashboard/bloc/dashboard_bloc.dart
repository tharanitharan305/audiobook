import 'package:audiobook/dashboard/bloc/dashboard_event.dart';
import 'package:audiobook/dashboard/bloc/dashboard_state.dart';
import 'package:audiobook/dashboard/data/dashboard_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardBloc extends Bloc<DashboardEvent,DashboardState>{
  DashboardRepo dashboardRepo;
  DashboardBloc({required this.dashboardRepo}) : super(DashBoardLoading()){
    on<AddFileToDashboard>((event, emit) async {
      emit(DashBoardLoading());
      try{
        dashboardRepo.addFile(event.doc);
        emit(DashBoardLoaded(documents: await dashboardRepo.getFiles()));
      }catch(e){
        emit(DashBoardError(message: e.toString()));
      }
    });
  on<DeleteFileFromDashboard>((event, emit) async {
    emit(DashBoardLoading());
    try {
      dashboardRepo.deleteFile(event.doc);
      emit(DashBoardLoaded(documents: await dashboardRepo.getFiles()));
    } catch (e) {
      emit(DashBoardError(message: e.toString()));
    }
  });
    on<RefreshDashBoard>((event, emit) async {
      emit(DashBoardLoading());

      try {
        final value = await dashboardRepo.getFiles();

        if (value.isEmpty) {
          emit(DashBoardEmpty());
        } else {
          emit(DashBoardLoaded(documents: value));
        }
      } catch (e) {
        emit(DashBoardError(message: e.toString()));
      }
    });

  }
}