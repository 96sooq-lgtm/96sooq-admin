import 'package:_96sooq_admin/features/terms_and_conditions/view/terms_and_condition_view_desktop.dart';
import 'package:_96sooq_admin/features/terms_and_conditions/view/terms_and_condition_view_mobile.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class TermsAndConditionView extends StatelessWidget {
  const TermsAndConditionView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => TermsAndConditionViewMobile(),
      desktop: (context) => TermsAndConditionViewDesktop(),
    );
  }
}
