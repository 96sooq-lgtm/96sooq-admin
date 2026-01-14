import 'package:_96sooq_admin/features/ad_bannner/view/ad_banner_view_desktop.dart';
import 'package:_96sooq_admin/features/ad_bannner/view/ad_banner_view_mobile.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdBannerView extends StatelessWidget {
  const AdBannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => AdBannerViewMobile(),
      desktop: (context) => AdBannerViewDesktop(),
    );
  }
}
