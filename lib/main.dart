import 'package:audiobook/theme/bloc/themeBloc.dart';
import 'package:audiobook/theme/bloc/themeState.dart';
import 'package:audiobook/theme/data/app_theme.dart';
import 'package:audiobook/theme/data/theme_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login/bloc/loginBloc.dart';
import 'login/bloc/loginState.dart';
import 'login/ui/loginui.dart';

void main() {
  final themeService = ThemeService();
  final themeBloc = ThemeBloc(themeService);
  final loginBloc = LoginBloc();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => themeService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => themeBloc),
          BlocProvider(create: (_) => loginBloc),
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
                return const Scaffold(
                  body: Center(child: Text("Home")),
                );
              }
              return LoginPage();
            },
          ),
        );
      },
    );
  }
}