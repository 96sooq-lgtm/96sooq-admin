import 'package:_96sooq_admin/constants/strings.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/auth/bloc/auth_bloc.dart';
import 'package:_96sooq_admin/features/auth/bloc/auth_event.dart';
import 'package:_96sooq_admin/features/home/view/home_view.dart';
import 'package:_96sooq_admin/features/category/view/category_view.dart';
import 'package:_96sooq_admin/features/subcategory/view/subcategory_view.dart';
import 'package:_96sooq_admin/features/promotion/view/promotion_view.dart';
import 'package:_96sooq_admin/features/ad_bannner/view/ad_banner_view.dart';
import 'package:_96sooq_admin/features/stores/view/offer_listing_view.dart';
import 'package:_96sooq_admin/features/user_management/view/user_management_view.dart';
import 'package:_96sooq_admin/features/request_approval/view/request_approval_view.dart';
import 'package:_96sooq_admin/features/payments/view/payments_view.dart';
import 'package:_96sooq_admin/features/terms_and_conditions/view/terms_and_condition_view.dart';
import 'package:_96sooq_admin/features/settings/view/settings_view.dart';
import 'package:_96sooq_admin/features/root/cubit/admin_navigation_cubit.dart';
import 'package:_96sooq_admin/features/home/bloc/dashboard_bloc.dart';
import 'package:_96sooq_admin/features/home/bloc/dashboard_event.dart';
import 'package:_96sooq_admin/features/home/bloc/dashboard_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AdminRootMobileView extends StatefulWidget {
  const AdminRootMobileView({super.key});

  @override
  State<AdminRootMobileView> createState() => _AdminRootMobileViewState();
}

class _AdminRootMobileViewState extends State<AdminRootMobileView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> adminPages = [
    const HomeView(),
    const CategoryView(),
    const SubcategoryView(),
    const PromotionView(),
    const AdBannerView(),
    const StoreListingScreen(),
    const UserManagementView(),
    const RequestApprovalView(),
    const PaymentsView(),
    const TermsAndConditionView(),
    const SettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    // Load dashboard metrics on initial build (dashboard is the default page)
    context.read<DashboardBloc>().add(LoadDashboardMetrics());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminNavigationCubit(),
      child: BlocListener<AdminNavigationCubit, int>(
        listener: (context, selectedIndex) {
          if (selectedIndex == 0) {
            context.read<DashboardBloc>().add(LoadDashboardMetrics());
          }
        },
        child: BlocBuilder<AdminNavigationCubit, int>(
          builder: (context, selectedIndex) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: const Color(0xFFF9FAFB),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DynamicText('96 Sooq Admin', style: AppThemes.f16w500),
                  ],
                ),
              ),
              drawer: _buildDrawer(context, selectedIndex),
              body: adminPages[selectedIndex],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, int currentIndex) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () => Navigator.pop(
                      context,
                    ), // Typically menu icon closes it too if acting symmetrically
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DynamicText(
                      '96 Sooq Admin',
                      style: AppThemes.f16w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Drawer Items
            Expanded(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, dashboardState) {
                  int pendingCount = 0;
                  if (dashboardState is DashboardLoaded) {
                    pendingCount = dashboardState.metrics.pendingRequests;
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    children: [
                      _buildDrawerItem(
                        context,
                        0,
                        'Dashboard',
                        currentIndex,
                        AssetPath.homeSelectedIc,
                        AssetPath.homeUnSelectedIc,
                      ),
                      _buildDrawerItem(
                        context,
                        1,
                        'Category',
                        currentIndex,
                        AssetPath.categorySelectedIc,
                        AssetPath.categoryUnSelectedIc,
                      ),
                      _buildDrawerItem(
                        context,
                        2,
                        'Sub Category',
                        currentIndex,
                        AssetPath.subcategorySelectedIc,
                        AssetPath.subcategoryUnSelectedIc,
                      ),
                      _buildDrawerItem(
                        context,
                        3,
                        'Subscriptions',
                        currentIndex,
                        AssetPath.subscriptionSelectedIc,
                        AssetPath.subscriptionUnSelectedIc,
                      ),
                      _buildDrawerItem(
                        context,
                        4,
                        'Ad Banner',
                        currentIndex,
                        AssetPath.adBannerSelectedIc,
                        AssetPath.adBannerUnSelectedIc,
                      ),
                      _buildDrawerItem(
                        context,
                        5,
                        'Stores',
                        currentIndex,
                        AssetPath.offerListingSelectedIc,
                        AssetPath.offerListingUnSelectedIc,
                      ),
                      _buildDrawerItem(
                        context,
                        6,
                        'User Management',
                        currentIndex,
                        AssetPath.userManagementSelectedIc,
                        AssetPath.userManagementUnselectedIc,
                      ),
                      _buildDrawerItem(
                        context,
                        7,
                        'Request Approval',
                        currentIndex,
                        AssetPath.requestApprovalSelectedIc,
                        AssetPath.requestApprovalUnSelectedIc,
                        notificationCount: pendingCount,
                      ),
                      _buildDrawerItem(
                        context,
                        8,
                        'Payments',
                        currentIndex,
                        AssetPath.paymentSelectedIc,
                        AssetPath.paymentUnSelectedIc,
                      ),
                      _buildDrawerItem(
                        context,
                        9,
                        'Terms And Conditions',
                        currentIndex,
                        AssetPath.termsAndConditionsSelectedIc,
                        AssetPath.termsAndConditionsUnselectedIc,
                      ),
                      _buildDrawerItem(
                        context,
                        10,
                        'Settings',
                        currentIndex,
                        AssetPath.settingsSelectedIc,
                        AssetPath.settingsUnSelectedIc,
                      ),
                      const SizedBox(height: 20),
                      // Logout Button
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.redAccent,
                        ),
                        title: DynamicText(
                          "Logout",
                          style: AppThemes.f16w500.copyWith(
                            color: Colors.redAccent,
                          ),
                        ),
                        onTap: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    int index,
    String title,
    int currentIndex,
    String selectedIc,
    String unselectedIc, {
    int? notificationCount,
  }) {
    final bool isSelected = currentIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: SvgPicture.asset(
          isSelected ? selectedIc : unselectedIc,
          height: 22,
          colorFilter: ColorFilter.mode(
            isSelected ? Colors.white : Colors.black87,
            BlendMode.srcIn,
          ),
        ),
        title: DynamicText(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        trailing: (notificationCount != null && notificationCount > 0)
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  notificationCount.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () {
          context.read<AdminNavigationCubit>().changePage(index);
          Navigator.pop(context); // Close drawer
        },
      ),
    );
  }
}
