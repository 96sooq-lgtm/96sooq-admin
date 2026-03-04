import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/strings.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/home/widgets/icon_and_text_widget.dart';
import 'package:_96sooq_admin/features/home/widgets/quick_actions_widget.dart';
import 'package:_96sooq_admin/features/root/cubit/admin_navigation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:_96sooq_admin/features/home/bloc/dashboard_bloc.dart';
import 'package:_96sooq_admin/features/home/bloc/dashboard_state.dart';

class HomeViewMobile extends StatefulWidget {
  const HomeViewMobile({super.key});

  @override
  State<HomeViewMobile> createState() => _HomeViewMobileState();
}

class _HomeViewMobileState extends State<HomeViewMobile> {
  final quickActionItems = [
    {
      'icon': AssetPath.categoryUnSelectedIc,
      'title': 'Add Category',
      'action': 'add_category',
    },
    {
      'icon': AssetPath.subcategoryUnSelectedIc,
      'title': 'Add sub category',
      'action': 'add_subcategory',
    },
    {
      'icon': AssetPath.addBannerIc,
      'title': 'Add Ad Banner',
      'action': 'add_banner',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldColor,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DynamicText("Dashboard", style: AppThemes.f24w600),
                  const SizedBox(height: 8),
                  DynamicText(
                    "Welcome to your marketplace admin panel",
                    style: AppThemes.f16w400,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                final List<Map<String, dynamic>> dashboardItems = [
                  {
                    'icon': AssetPath.totalUsersIc,
                    'title': 'Users',
                    'index': 6,
                    'count': state is DashboardLoaded
                        ? state.metrics.totalUsers
                        : null,
                  },
                  {
                    'icon': AssetPath.storeIc,
                    'title': 'Stores',
                    'index': 5,
                    'count': state is DashboardLoaded
                        ? state.metrics.totalStores
                        : null,
                  },
                  {
                    'icon': AssetPath.listingIc,
                    'title': 'Listings',
                    'index': -1, // No navigation
                    'count': state is DashboardLoaded
                        ? state.metrics.totalListings
                        : null,
                  },
                  {
                    'icon': AssetPath.dealsIc,
                    'title': 'Transactions',
                    'index': 8, // Payments Tab
                    'count': state is DashboardLoaded
                        ? state.metrics.totalTransactions
                        : null,
                  },
                  {
                    'icon': AssetPath.pendingRequestIc,
                    'title': 'Pending Request',
                    'index': 7, // Request Approval Tab
                    'count': state is DashboardLoaded
                        ? state.metrics.pendingRequests
                        : null,
                  },
                  {
                    'icon': AssetPath.dealsIc,
                    'title': 'Revenue',
                    'index': -1, // No navigation
                    'count': state is DashboardLoaded
                        ? state.metrics.totalRevenue.toInt()
                        : null,
                  },
                ];

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = dashboardItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: IconAndTextWidget(
                        svgPath: item['icon'] as String,
                        isLoading: state is DashboardLoading,
                        count: item['count'] as int?,
                        title: item['title'] as String,
                        onTap: () {
                          final targetIndex = item['index'] as int;
                          if (targetIndex != -1) {
                            context.read<AdminNavigationCubit>().changePage(
                              targetIndex,
                            );
                          }
                        },
                      ),
                    );
                  }, childCount: dashboardItems.length),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DynamicText("Quick Actions", style: AppThemes.f20w600),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = quickActionItems[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: QuickActionsWidget(
                    svgPath: item['icon'] as String,
                    title: item['title'] as String,
                    onTap: () {
                      switch (item['action']) {
                        case 'add_category':
                          QuickActionPopupContent.showAddCategoryDialog(
                            context,
                          );
                          break;

                        case 'add_subcategory':
                          QuickActionPopupContent.showAddSubCategoryDialog(
                            context,
                          );
                          break;

                        case 'add_banner':
                          context.read<AdminNavigationCubit>().changePage(4);
                          break;
                      }
                    },
                  ),
                );
              }, childCount: quickActionItems.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }
}
