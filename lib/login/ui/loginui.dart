import 'package:audiobook/login/bloc/loginBloc.dart';
import 'package:audiobook/login/bloc/loginState.dart';
import 'package:audiobook/login/widget/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../theme/bloc/themeBloc.dart';
import '../../theme/bloc/themeEvent.dart';
import '../../theme/bloc/themeState.dart';
import '../widget/createaccount.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text("Audiobook"),
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              final isDark = state.themeMode == ThemeMode.dark;

              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  context.read<ThemeBloc>().add(ToggleTheme());
                },
              );
            },
          ),
        ],
      ),
      body: AuthWidget()
    );
  }
}
