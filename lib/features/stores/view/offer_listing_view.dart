import 'package:_96sooq_admin/features/stores/view/offer_listing_view_desktop.dart';
import 'package:_96sooq_admin/features/stores/view/offer_listing_view_mobile.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class StoreListingScreen extends StatelessWidget {
  const StoreListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => const OfferListingViewMobile(),
      desktop: (context) => const OfferListingViewDesktop(),
    );
  }
}
