import 'package:_96sooq_admin/constants/strings.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/root/cubit/admin_navigation_cubit.dart';
import 'package:_96sooq_admin/features/root/widgets/admin_sidebar_item_widget.dart';
// IMPORT YOUR CUBIT HERE
import 'package:_96sooq_admin/features/home/bloc/dashboard_bloc.dart';
import 'package:_96sooq_admin/features/home/bloc/dashboard_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminSidebarWidget extends StatelessWidget {
  const AdminSidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the current index from the Cubit
    final int currentIndex = context.watch<AdminNavigationCubit>().state;

    return Container(
      width: 360,
      padding: const EdgeInsets.only(left: 28, right: 28, bottom: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, dashboardState) {
          int pendingCount = 0;
          if (dashboardState is DashboardLoaded) {
            pendingCount = dashboardState.metrics.pendingRequests;
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                _buildSidebarItem(
                  context,
                  0,
                  'Dashboard',
                  currentIndex,
                  AssetPath.homeSelectedIc,
                  AssetPath.homeUnSelectedIc,
                ),
                _buildSidebarItem(
                  context,
                  1,
                  'Category',
                  currentIndex,
                  AssetPath.categorySelectedIc,
                  AssetPath.categoryUnSelectedIc,
                ),
                _buildSidebarItem(
                  context,
                  2,
                  'Sub Category',
                  currentIndex,
                  AssetPath.subcategorySelectedIc,
                  AssetPath.subcategoryUnSelectedIc,
                ),
                _buildSidebarItem(
                  context,
                  3,
                  'Subscriptions',
                  currentIndex,
                  AssetPath.subscriptionSelectedIc,
                  AssetPath.subscriptionUnSelectedIc,
                ),
                _buildSidebarItem(
                  context,
                  4,
                  'Ad Banner',
                  currentIndex,
                  AssetPath.adBannerSelectedIc,
                  AssetPath.adBannerUnSelectedIc,
                ),
                _buildSidebarItem(
                  context,
                  5,
                  'Stores',
                  currentIndex,
                  AssetPath.offerListingSelectedIc,
                  AssetPath.offerListingUnSelectedIc,
                ),
                _buildSidebarItem(
                  context,
                  6,
                  'User Management',
                  currentIndex,
                  AssetPath.userManagementSelectedIc,
                  AssetPath.userManagementUnselectedIc,
                ),
                _buildSidebarItem(
                  context,
                  7,
                  'Request Approval',
                  currentIndex,
                  AssetPath.requestApprovalSelectedIc,
                  AssetPath.requestApprovalUnSelectedIc,
                  notificationCount: pendingCount,
                ),
                _buildSidebarItem(
                  context,
                  8,
                  'Payments',
                  currentIndex,
                  AssetPath.paymentSelectedIc,
                  AssetPath.paymentUnSelectedIc,
                ),
                // _buildSidebarItem(
                //   context,
                //   9,
                //   'Notifications',
                //   currentIndex,
                //   AssetPath.subscriptionSelectedIc,
                //   AssetPath.subscriptionUnSelectedIc,
                // ),
                _buildSidebarItem(
                  context,
                  9,
                  'Terms And Conditions',
                  currentIndex,
                  AssetPath.termsAndConditionsSelectedIc,
                  AssetPath.termsAndConditionsUnselectedIc,
                ),
                _buildSidebarItem(
                  context,
                  10,
                  'Settings',
                  currentIndex,
                  AssetPath.settingsSelectedIc,
                  AssetPath.settingsUnSelectedIc,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebarItem(
    BuildContext context, // Added context
    int index,
    String title,
    int currentIndex, // Pass the current index
    String selectedIc,
    String unselectedIc, {
    int? notificationCount,
  }) {
    final bool isSelected = currentIndex == index;

    return AdminSidebarItemWidget(
      index: index,
      title: DynamicText(
        title,
        style: TextStyle(
          // White if selected, Black if not
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      svgAssetSelected: selectedIc,
      svgAssetNotSelected: unselectedIc,
      notificationCount: notificationCount,
    );
  }
}
