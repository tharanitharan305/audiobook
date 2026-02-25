import 'package:audiobook/audio/data/audioService.dart';
import 'package:audiobook/home.dart';
import 'package:audiobook/summarize/bloc/summary_bloc.dart';
import 'package:audiobook/summarize/data/summary_service.dart';
import 'package:audiobook/theme/bloc/themeBloc.dart';
import 'package:audiobook/theme/bloc/themeState.dart';
import 'package:audiobook/theme/data/app_theme.dart';
import 'package:audiobook/theme/data/theme_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'audio/bloc/audio_bloc.dart';
import 'dashboard/bloc/dashboard_bloc.dart';
import 'dashboard/data/dashboard_repo.dart';
import 'dashboard/data/dashboard_service.dart';
import 'login/bloc/loginBloc.dart';
import 'login/bloc/loginState.dart';
import 'login/ui/loginui.dart';

void main() {
  final themeService = ThemeService();
  final themeBloc = ThemeBloc(themeService);
  final loginBloc = LoginBloc();
final dashBoardService = DashboardService();
final dashboardRepo = DashboardRepo(service: dashBoardService);
final dashboardBloc = DashboardBloc(dashboardRepo: dashboardRepo);
final summaryService = SummaryService();
final summaryBloc = SummaryBloc(service: summaryService);
final audioEngineService=AudioEngineService()..init();
final audioService=MockAudioService();
final audioBloc=AudioBloc(documentService: audioService, engine: audioEngineService);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => themeService),
        RepositoryProvider(create: (_) => dashboardRepo),
        RepositoryProvider(create: (_)=> summaryService),
        RepositoryProvider(create: (_)=>audioEngineService),
        RepositoryProvider(create: (_)=>audioService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => themeBloc),
          BlocProvider(create: (_) => loginBloc),
          BlocProvider(create: (_) => dashboardBloc),
          BlocProvider(create: (_)=>summaryBloc),
          BlocProvider(create: (_)=>audioBloc)
        ],
        child: const MyApp(),
      ),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          theme: AppTheme.lightTheme(themeState.accentColor),
          darkTheme: AppTheme.darkTheme(themeState.accentColor),
          themeMode: themeState.themeMode,

          home: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              if (state is LoggedIn) {
                return HomeScreen();
              }
              return LoginPage();
            },
          ),
        );
      },
    );
  }
}