import 'package:_96sooq_admin/features/auth/login/view/login_view_desktop.dart';
import 'package:_96sooq_admin/features/auth/login/view/login_view_mobile.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => LoginViewMobile(),
      desktop: (context) => LoginViewDesktop(),
    );
  }
}
