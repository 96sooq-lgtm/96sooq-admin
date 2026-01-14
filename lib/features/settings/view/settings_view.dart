import 'package:_96sooq_admin/features/offer_listings/view/offer_listing_view_desktop.dart';
import 'package:_96sooq_admin/features/offer_listings/view/offer_listing_view_mobile.dart';
import 'package:_96sooq_admin/features/settings/view/settings_view_desktop.dart';
import 'package:_96sooq_admin/features/settings/view/settings_view_mobile.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => SettingsViewMobile(),
      desktop: (context) => SettingsViewDesktop(),
    );
  }
}
