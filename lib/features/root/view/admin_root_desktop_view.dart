import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/features/category/view/category_view.dart';
import 'package:_96sooq_admin/features/home/view/home_view.dart';
import 'package:_96sooq_admin/features/root/cubit/admin_navigation_cubit.dart';
import 'package:_96sooq_admin/features/root/widgets/admin_sidebar_widget.dart';
import 'package:_96sooq_admin/features/subcategory/view/subcategory_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminRootDesktopView extends StatefulWidget {
  const AdminRootDesktopView({super.key});

  @override
  State<AdminRootDesktopView> createState() => _AdminRootDesktopViewState();
}

class _AdminRootDesktopViewState extends State<AdminRootDesktopView> {
  final List<Widget> adminPages = [
    const HomeView(),
    const CategoryView(),
    const SubcategoryView(),
  ];
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminNavigationCubit(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Column(
          children: [
            Container(
              height: 98,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE1E1E1)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Row(
                  mainAxisAlignment: .center,
                  children: [
                    Text('96 Sooq Admin', style: AppThemes.f24w400),
                    Spacer(),
                    InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Color(0xFF707070)),
                          Text(
                            "Logout",
                            style: AppThemes.f24w500.copyWith(
                              color: Color(0xFF707070),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  const AdminSidebarWidget(),
                  // Main Content
                  Expanded(
                    child: BlocBuilder<AdminNavigationCubit, int>(
                      builder: (context, selectedIndex) {
                        return adminPages[selectedIndex];
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
