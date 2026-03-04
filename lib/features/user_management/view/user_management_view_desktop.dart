import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/user_management/widgets/user_details_dialog.dart';

import 'package:_96sooq_admin/features/user_management/widgets/user_listing_widget.dart';
import 'package:_96sooq_admin/features/user_management/bloc/user_bloc.dart';
import 'package:_96sooq_admin/features/user_management/bloc/user_event.dart';
import 'package:_96sooq_admin/features/user_management/bloc/user_state.dart';
import 'package:_96sooq_admin/features/user_management/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserManagementViewDesktop extends StatefulWidget {
  const UserManagementViewDesktop({super.key});

  @override
  State<UserManagementViewDesktop> createState() =>
      _UserManagementViewDesktopState();
}

class _UserManagementViewDesktopState extends State<UserManagementViewDesktop> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _mainScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(_onMainScroll);
  }

  void _onMainScroll() {
    if (_mainScrollController.position.pixels >=
        _mainScrollController.position.maxScrollExtent - 200) {
      context.read<UserBloc>().add(LoadMoreUsers());
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _mainScrollController.removeListener(_onMainScroll);
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: CustomScrollView(
        controller: _mainScrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 36),
                  DynamicText("User Management", style: AppThemes.f28w600),
                  const SizedBox(height: 10),
                  DynamicText(
                    "Manage all users on your marketplace",
                    style: AppThemes.f20w400,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE1E1E1)),
                    ),
                    child: Column(
                      children: [
                        /// Top Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 55,
                            vertical: 55,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(
                              mainAxisAlignment: .center,
                              crossAxisAlignment: .center,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: CustomTextFormField(
                                    controller: searchController,
                                    onChanged: (_) => setState(() {}),
                                    labelText: "Search name or email..",
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      color: Color(0xFF99A1Af),
                                    ),
                                  ),
                                ),
                                Spacer(flex: 2),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF9FAFB),
                            border: Border.all(color: Color(0xFFE1E1E1)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: const [
                                SizedBox(width: 40),
                                Expanded(
                                  flex: 2,
                                  child: DynamicText(
                                    'Name',
                                    style: AppThemes.f20w500,
                                  ),
                                ),
                                SizedBox(width: 40),
                                Expanded(
                                  flex: 2,
                                  child: DynamicText(
                                    'Email',
                                    style: AppThemes.f20w500,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: DynamicText(
                                      'Status',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: DynamicText(
                                      'Actions',
                                      style: AppThemes.f20w500,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        BlocBuilder<UserBloc, UserState>(
                          builder: (context, state) {
                            List<UserModel> users = state.users;
                            bool isLoading = state.status == UserStatus.loading;
                            bool hasReachedMax = state.hasReachedMax;

                            final filteredUsers = users.where((user) {
                              if (query.isEmpty) return true;
                              return user.name.toLowerCase().contains(query) ||
                                  (user.email != null &&
                                      user.email!.toLowerCase().contains(
                                        query,
                                      ));
                            }).toList();

                            if (isLoading && users.isEmpty) {
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 6,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  child: Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (filteredUsers.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(40),
                                child: Center(
                                  child: DynamicText(
                                    'No results found',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  filteredUsers.length +
                                  (state.isFetchingMore && !hasReachedMax
                                      ? 1
                                      : 0),
                              itemBuilder: (context, index) {
                                if (index >= filteredUsers.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                final user = filteredUsers[index];
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      context.read<UserBloc>().add(
                                        LoadUserDetails(user.id),
                                      );
                                      showDialog(
                                        context: context,
                                        builder: (_) =>
                                            UserDetailsDialog(userId: user.id),
                                      );
                                    },
                                    hoverColor: Colors.black.withOpacity(0.04),
                                    child: UserListingWidget(
                                      userName: user.name,
                                      userEmail: user.email ?? 'N/A',
                                      status: user.isActive
                                          ? 'Active'
                                          : 'Block',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
