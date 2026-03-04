import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/user_management/widgets/user_details_dialog.dart';
import 'package:_96sooq_admin/features/user_management/bloc/user_bloc.dart';
import 'package:_96sooq_admin/features/user_management/bloc/user_event.dart';
import 'package:_96sooq_admin/features/user_management/bloc/user_state.dart';
import 'package:_96sooq_admin/features/user_management/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserManagementViewMobile extends StatefulWidget {
  const UserManagementViewMobile({super.key});

  @override
  State<UserManagementViewMobile> createState() =>
      _UserManagementViewMobileState();
}

class _UserManagementViewMobileState extends State<UserManagementViewMobile> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _tableScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(_onMainScroll);
    // Fetch initial list if not already loaded (handled currently in main.dart)
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
    _tableScrollController.dispose();
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
                  const SizedBox(height: 24),
                  DynamicText('User Management', style: AppThemes.f20w600),
                  const SizedBox(height: 6),
                  DynamicText(
                    'Manage all users on your marketplace',
                    style: AppThemes.f14w400,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomTextFormField(
                      controller: searchController,
                      onChanged: (_) => setState(() {}),
                      labelText: 'Search name or email..',
                      fillColor: Colors.white,
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF99A1Af),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE1E1E1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: BlocBuilder<UserBloc, UserState>(
                        builder: (context, state) {
                          List<UserModel> users = state.users;
                          bool isLoading = state.status == UserStatus.loading;
                          bool hasReachedMax = state.hasReachedMax;

                          final filteredUsers = users.where((user) {
                            if (query.isEmpty) return true;
                            return user.name.toLowerCase().contains(query) ||
                                (user.email != null &&
                                    user.email!.toLowerCase().contains(query));
                          }).toList();

                          return Scrollbar(
                            controller: _tableScrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _tableScrollController,
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 980,
                                child: Column(
                                  children: [
                                    _UserTableHeader(),
                                    if (isLoading && users.isEmpty)
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: 6,
                                        itemBuilder: (context, index) =>
                                            Padding(
                                              padding: EdgeInsets.only(
                                                bottom: index == 5 ? 0 : 16,
                                              ),
                                              child:
                                                  const _UserShimmerRowMobile(),
                                            ),
                                      )
                                    else if (filteredUsers.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.all(40),
                                        child: Center(
                                          child: DynamicText(
                                            'No results found',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            filteredUsers.length +
                                            (state.isFetchingMore &&
                                                    !hasReachedMax
                                                ? 1
                                                : 0),
                                        itemBuilder: (context, index) {
                                          if (index >= filteredUsers.length) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 16,
                                              ),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
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
                                                      UserDetailsDialog(
                                                        userId: user.id,
                                                      ),
                                                );
                                              },
                                              hoverColor: Colors.black
                                                  .withOpacity(0.04),
                                              child: _UserRowMobile(
                                                name: user.name,
                                                email: user.email ?? 'N/A',
                                                status: user.isActive
                                                    ? 'Active'
                                                    : 'Block',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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

class _UserTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE1E1E1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: const [
            SizedBox(width: 20),
            Expanded(
              flex: 3,
              child: DynamicText('Name', style: AppThemes.f14w600),
            ),
            Expanded(
              flex: 4,
              child: DynamicText('Email', style: AppThemes.f14w600),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: DynamicText('Status', style: AppThemes.f14w600),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: DynamicText('Actions', style: AppThemes.f14w600),
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}

class _UserRowMobile extends StatelessWidget {
  final String name;
  final String email;
  final String status;

  const _UserRowMobile({
    required this.name,
    required this.email,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Active';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEFEFEF))),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Expanded(flex: 3, child: DynamicText(name, style: AppThemes.f14w400)),
          Expanded(
            flex: 4,
            child: DynamicText(email, style: AppThemes.f14w400),
          ),
          Expanded(
            flex: 2,
            child: Center(child: _StatusChip(isActive: isActive)),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: isActive
                  ? IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF008258),
                        size: 20,
                      ),
                    )
                  : IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFFF93939),
                        size: 20,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _UserShimmerRowMobile extends StatelessWidget {
  const _UserShimmerRowMobile();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: 0.85),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Row(
            children: const [
              SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: _ShimmerBoxMobile(width: double.infinity, height: 16),
              ),
              Expanded(
                flex: 4,
                child: _ShimmerBoxMobile(width: double.infinity, height: 16),
              ),
              Expanded(
                flex: 2,
                child: Center(child: _ShimmerBoxMobile(width: 70, height: 16)),
              ),
              Expanded(
                flex: 2,
                child: Center(child: _ShimmerBoxMobile(width: 50, height: 16)),
              ),
              SizedBox(width: 20),
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;

  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDBFCE7) : const Color(0xFFFFE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DynamicText(
        isActive ? 'Active' : 'Block',
        style: AppThemes.f12w500.copyWith(
          color: isActive ? const Color(0xFF1E8E4E) : const Color(0xFFF93939),
        ),
      ),
    );
  }
}

class _ShimmerBoxMobile extends StatelessWidget {
  final double width;
  final double height;

  const _ShimmerBoxMobile({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
