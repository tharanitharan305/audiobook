import 'package:audiobook/login/widget/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/loginBloc.dart';
import '../bloc/loginEvent.dart';
import '../bloc/loginState.dart';
import '../data/model.dart';

class AuthWidget extends StatefulWidget {
  const AuthWidget({super.key});

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            final bool isCreate = state is CreateAccount;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 400,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.08),
                    blurRadius: 25,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // 🔥 LOGO ON TOP
                  const logo(),
                  const SizedBox(height: 20),

                  Text(
                    isCreate ? "Create account" : "Welcome back",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Name field only for Create
                  if (isCreate)
                    Column(
                      children: [
                        _buildTextField(
                          controller: nameController,
                          hint: "Full name",
                          icon: Icons.person_outline,
                          theme: theme,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  _buildTextField(
                    controller: emailController,
                    hint: "Email",
                    icon: Icons.email_outlined,
                    theme: theme,
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: passwordController,
                    hint: "Password",
                    icon: Icons.lock_outline,
                    theme: theme,
                    obscure: true,
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        final user = User(
                          name: nameController.text,
                          email: emailController.text,
                          password: passwordController.text,
                        );

                        if (isCreate) {
                          context.read<LoginBloc>().add(
                            CreateAccountEvent(user: user),
                          );
                        } else {
                          context.read<LoginBloc>().add(
                            Login(user: user),
                          );
                        }
                      },
                      child: Text(
                        isCreate ? "Create Account" : "Login",
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isCreate
                            ? "Already have an account? "
                            : "Don't have an account? ",
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<LoginBloc>().add(ToggleLogin());
                        },
                        child: Text(
                          isCreate ? "Sign in" : "Create account",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: theme.iconTheme.color),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor ??
            theme.colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}