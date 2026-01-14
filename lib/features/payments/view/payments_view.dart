import 'package:_96sooq_admin/features/offer_listings/view/offer_listing_view_desktop.dart';
import 'package:_96sooq_admin/features/offer_listings/view/offer_listing_view_mobile.dart';
import 'package:_96sooq_admin/features/payments/view/payments_view_desktop.dart';
import 'package:_96sooq_admin/features/payments/view/payments_view_mobile.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class PaymentsView extends StatelessWidget {
  const PaymentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => PaymentsViewMobile(),
      desktop: (context) => PaymentsViewDesktop(),
    );
  }
}
