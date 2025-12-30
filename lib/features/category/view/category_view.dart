import 'package:_96sooq_admin/features/category/view/category_desktop_view.dart';
import 'package:_96sooq_admin/features/category/view/category_mobile_view.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => CategoryMobileView(),
      desktop: (context) => CategoryDesktopView(),
    );
  }
}
