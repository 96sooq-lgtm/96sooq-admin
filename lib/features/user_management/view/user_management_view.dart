import 'package:_96sooq_admin/features/user_management/view/user_management_view_desktop.dart';
import 'package:_96sooq_admin/features/user_management/view/user_management_view_mobile.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class UserManagementView extends StatelessWidget {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => UserManagementViewMobile(),
      desktop: (context) => UserManagementViewDesktop(),
    );
  }
}
