import 'package:_96sooq_admin/features/subcategory/model/subcategory_model.dart';
import 'package:_96sooq_admin/features/subcategory/view/attribute/attribute_desktop_view.dart';
import 'package:_96sooq_admin/features/subcategory/view/attribute/attribute_mobile_view.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AttributeView extends StatelessWidget {
  const AttributeView({super.key, required this.subcategory});

  final SubcategoryModel subcategory;

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => AttributeMobileView(subcategory: subcategory),
      desktop: (context) => AttributeDesktopView(subcategory: subcategory),
    );
  }
}
