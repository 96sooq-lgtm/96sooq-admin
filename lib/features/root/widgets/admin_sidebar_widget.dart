import 'package:_96sooq_admin/constants/strings.dart';
import 'package:_96sooq_admin/features/root/widgets/admin_sidebar_item_widget.dart';
import 'package:flutter/material.dart';

class AdminSidebarWidget extends StatelessWidget {
  const AdminSidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.only(left: 28, right: 28, bottom: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 30),
            AdminSidebarItemWidget(
              index: 0,
              title: 'Dashboard',
              svgAssetSelected: AssetPath.homeSelectedIc,
              svgAssetNotSelected: AssetPath.homeUnSelectedIc,
            ),
            AdminSidebarItemWidget(
              index: 1,
              title: 'Category',
              svgAssetSelected: AssetPath.categorySelectedIc,
              svgAssetNotSelected: AssetPath.categoryUnSelectedIc,
            ),
            AdminSidebarItemWidget(
              index: 2,
              title: 'Sub Category',
              svgAssetSelected: AssetPath.subcategorySelectedIc,
              svgAssetNotSelected: AssetPath.subcategoryUnSelectedIc,
            ),
            AdminSidebarItemWidget(
              index: 3,
              title: 'Subscriptions',
              svgAssetSelected: AssetPath.subscriptionSelectedIc,
              svgAssetNotSelected: AssetPath.subscriptionUnSelectedIc,
            ),
            AdminSidebarItemWidget(
              index: 4,
              title: 'Ad Banner',
              svgAssetSelected: AssetPath.subscriptionSelectedIc,
              svgAssetNotSelected: AssetPath.subscriptionUnSelectedIc,
            ),
            AdminSidebarItemWidget(
              index: 5,
              title: 'Offer Listing',
              svgAssetSelected: AssetPath.subscriptionSelectedIc,
              svgAssetNotSelected: AssetPath.subscriptionUnSelectedIc,
            ),
            AdminSidebarItemWidget(
              index: 6,
              title: 'User Management',
              svgAssetSelected: AssetPath.subscriptionSelectedIc,
              svgAssetNotSelected: AssetPath.subscriptionUnSelectedIc,
            ),
            AdminSidebarItemWidget(
              index: 7,
              title: 'Request Approval',
              svgAssetSelected: AssetPath.subscriptionSelectedIc,
              svgAssetNotSelected: AssetPath.subscriptionUnSelectedIc,
            ),
            AdminSidebarItemWidget(
              index: 8,
              title: 'Payments',
              svgAssetSelected: AssetPath.subscriptionSelectedIc,
              svgAssetNotSelected: AssetPath.subscriptionUnSelectedIc,
            ),
            AdminSidebarItemWidget(
              index: 9,
              title: 'Notifications',
              svgAssetSelected: AssetPath.subscriptionSelectedIc,
              svgAssetNotSelected: AssetPath.subscriptionUnSelectedIc,
            ),
            AdminSidebarItemWidget(
              index: 10,
              title: 'Terms And Conditions',
              svgAssetSelected: AssetPath.subscriptionSelectedIc,
              svgAssetNotSelected: AssetPath.subscriptionUnSelectedIc,
            ),
            AdminSidebarItemWidget(
              index: 11,
              title: 'Settings',
              svgAssetSelected: AssetPath.subscriptionSelectedIc,
              svgAssetNotSelected: AssetPath.subscriptionUnSelectedIc,
            ),
          ],
        ),
      ),
    );
  }
}
