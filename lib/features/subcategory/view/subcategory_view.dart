import 'package:_96sooq_admin/features/subcategory/view/subcategory_desktop_view.dart';
import 'package:_96sooq_admin/features/subcategory/view/subcategory_mobile_view.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SubcategoryView extends StatelessWidget {
  const SubcategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => SubcategoryMobileView(),
      desktop: (context) => SubcategoryDesktopView(),
    );
  }
}
