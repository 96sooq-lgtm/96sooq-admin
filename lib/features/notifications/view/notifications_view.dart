import 'package:_96sooq_admin/features/notifications/view/notfications_view_mobile.dart';
import 'package:_96sooq_admin/features/notifications/view/notifications_view_desktop.dart';
import 'package:_96sooq_admin/features/offer_listings/view/offer_listing_view_desktop.dart';
import 'package:_96sooq_admin/features/offer_listings/view/offer_listing_view_mobile.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => NotficationsViewMobile(),
      desktop: (context) => NotificationsViewDesktop(),
    );
  }
}
