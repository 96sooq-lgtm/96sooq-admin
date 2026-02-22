import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/strings.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/home/widgets/icon_and_text_widget.dart';
import 'package:_96sooq_admin/features/home/widgets/quick_actions_widget.dart';
import 'package:_96sooq_admin/features/root/cubit/admin_navigation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeViewDesktop extends StatefulWidget {
  const HomeViewDesktop({super.key});

  @override
  State<HomeViewDesktop> createState() => _HomeViewDesktopState();
}

class _HomeViewDesktopState extends State<HomeViewDesktop> {
  final dashboardItems = [
    {'icon': AssetPath.totalUsersIc, 'title': 'Users', 'index': 6},
    {'icon': AssetPath.storeIc, 'title': 'Stores', 'index': 5},
    {'icon': AssetPath.listingIc, 'title': 'Listings', 'index': 5},
    {'icon': AssetPath.dealsIc, 'title': 'Deals', 'index': 3},
    {
      'icon': AssetPath.pendingRequestIc,
      'title': 'Pending Request',
      'index': 7,
    },
  ];

  final quickActionItems = [
    {
      'icon': AssetPath.categoryUnSelectedIc,
      'title': 'Add Category',
      'action': 'add_category',
    },
    {
      'icon': AssetPath.subcategoryUnSelectedIc,
      'title': 'Add Subcategory',
      'action': 'add_subcategory',
    },
    {
      'icon': AssetPath.addBannerIc,
      'title': 'Add Banner',
      'action': 'add_banner',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 36),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DynamicText("Dashboard", style: AppThemes.f28w600),
                    const SizedBox(height: 10),
                    DynamicText(
                      "Welcome to your marketplace admin panel",
                      style: AppThemes.f20w400,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(right: 24, bottom: 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = dashboardItems[index];
                  return IconAndTextWidget(
                    svgPath: item['icon'] as String,
                    count: 5,
                    title: item['title'] as String,
                    onTap: () {
                      final targetIndex = item['index'] as int;
                      context.read<AdminNavigationCubit>().changePage(
                        targetIndex,
                      );
                    },
                  );
                }, childCount: dashboardItems.length),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DynamicText("Quick Actions", style: AppThemes.f28w600),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 3,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = quickActionItems[index];

                return QuickActionsWidget(
                  svgPath: item['icon'] as String,
                  title: item['title'] as String,
                  onTap: () {
                    switch (item['action']) {
                      case 'add_category':
                        QuickActionPopupContent.showAddCategoryDialog(context);
                        break;

                      case 'add_subcategory':
                        QuickActionPopupContent.showAddSubCategoryDialog(
                          context,
                        );
                        break;

                      case 'add_banner':
                        // showAddBannerDialog(context);
                        break;
                    }
                  },
                );
              }, childCount: quickActionItems.length),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 50)),
          ],
        ),
      ),
    );
  }
}
