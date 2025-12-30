import 'package:_96sooq_admin/features/home/view/home_view_desktop.dart';
import 'package:_96sooq_admin/features/home/view/home_view_mobile.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => HomeViewMobile(),
      desktop: (context) => HomeViewDesktop(),
    );
  }
}
