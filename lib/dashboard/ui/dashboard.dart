import 'package:audiobook/audio/widget/miniPlayer.dart';
import 'package:audiobook/dashboard/bloc/dashboard_event.dart';
import 'package:audiobook/dashboard/widget/docCard.dart';
import 'package:audiobook/dashboard/widget/fileUpload.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_state.dart';
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<DashboardBloc>().add(RefreshDashBoard());
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Dashboard",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
              //if(context.read<AudioBloc>().state.isPlaying)
                MiniAudioPlayer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Uploader(),
              ),
              BlocBuilder<DashboardBloc,DashboardState>(builder: (context, state) {
                if(state is DashBoardLoading){
                  return Center(child: CircularProgressIndicator(),);
                }
                if(state is DashBoardLoaded){
                  return Expanded(child: ListView(children: [
                    for(var doc in state.documents)
                        Doccard(doc: doc)
                  ],));
                }
                if(state is DashBoardError){
                  return Center(child: Text(state.message),);
                }
                if(state is DashBoardEmpty){
                  return Center(child: Text("No files found"),);
                }
                return Center(child: Text(state.toString()),);
              },),
            ],
          ),
        ),
      ),
    );
  }
}
