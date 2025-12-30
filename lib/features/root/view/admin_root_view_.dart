import 'package:_96sooq_admin/features/root/view/admin_root_desktop_view.dart';
import 'package:_96sooq_admin/features/root/view/admin_root_mobile_view.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdminRootView extends StatelessWidget {
  const AdminRootView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => AdminRootMobileView(),
      desktop: (context) => AdminRootDesktopView(),
    );
  }
}
