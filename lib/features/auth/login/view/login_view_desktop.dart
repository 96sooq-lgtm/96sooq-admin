import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/strings.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/auth/bloc/auth_bloc.dart';
import 'package:_96sooq_admin/features/auth/bloc/auth_event.dart';
import 'package:_96sooq_admin/features/auth/bloc/auth_state.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/root/view/admin_root_view_.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginViewDesktop extends StatefulWidget {
  const LoginViewDesktop({super.key});

  @override
  State<LoginViewDesktop> createState() => _LoginViewDesktopState();
}

class _LoginViewDesktopState extends State<LoginViewDesktop> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Helper to show the floating snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: DynamicText(
          message.replaceAll('Exception: ', ''), // Clean the message
          style: AppThemes.f16w300.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AdminRootView()),
            (route) => false,
          );
        } else if (state is AuthError) {
          _showErrorSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            backgroundColor: AppColors.scaffoldColor,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 150,
                  vertical: 80,
                ),
                child: Row(
                  children: [
                    // --- Left Panel (Branding) ---
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 722,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(60),
                            bottomLeft: Radius.circular(60),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 70,
                              ),
                              child: Image.asset(AssetPath.logo),
                            ),
                            const SizedBox(height: 40),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "96 Sooq Admin",
                                    style: AppThemes.f28w500.copyWith(
                                      color: AppColors.whiteTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  DynamicText(
                                    "Empowering your platform with powerful insights and seamless management tools.",
                                    style: AppThemes.f16w300.copyWith(
                                      color: AppColors.whiteTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- Right Panel (Login Form) ---
                    Expanded(
                      flex: 6,
                      child: Container(
                        height: 722,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(60),
                            bottomRight: Radius.circular(60),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 80,
                            vertical: 80,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DynamicText(
                                  "Welcome",
                                  style: AppThemes.f36w600,
                                ),
                                DynamicText(
                                  "Please enter your details to sign in.",
                                  style: AppThemes.f18w400,
                                ),
                                const SizedBox(height: 50),

                                // Email Field
                                DynamicText(
                                  "Email Address",
                                  style: AppThemes.f20w500,
                                ),
                                const SizedBox(height: 10),
                                CustomTextFormField(
                                  controller: emailController,
                                  labelText: "Email Address",
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Password Field
                                DynamicText(
                                  "Password",
                                  style: AppThemes.f20w500,
                                ),
                                const SizedBox(height: 10),
                                CustomTextFormField(
                                  controller: passwordController,
                                  labelText: "Password",
                                  obscureText: true,
                                  isPassword: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 40),

                                // Login Button
                                CustomButton(
                                  text: "Login",
                                  isLoading: state is AuthLoading,
                                  onPressed: () {
                                    // 1. Trigger Form Validation
                                    if (_formKey.currentState!.validate()) {
                                      // 2. Only call Bloc if form is valid
                                      context.read<AuthBloc>().add(
                                        LoginRequested(
                                          email: emailController.text.trim(),
                                          password: passwordController.text
                                              .trim(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
