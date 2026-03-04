import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/user_management/bloc/user_bloc.dart';
import 'package:_96sooq_admin/features/user_management/bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UserDetailsDialog extends StatelessWidget {
  final String userId;

  const UserDetailsDialog({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// Header
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 16,
                top: 16,
                bottom: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DynamicText('User Details', style: AppThemes.f20w600),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE1E1E1)),

            /// Body
            Flexible(
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state.detailStatus == UserDetailStatus.loading ||
                      state.detailStatus == UserDetailStatus.initial) {
                    return const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (state.detailStatus == UserDetailStatus.error) {
                    return Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Center(
                        child: DynamicText(
                          state.detailErrorMessage ?? 'Failed to load details.',
                          style: AppThemes.f14w500.copyWith(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  final user = state.userDetail;
                  if (user == null) return const SizedBox.shrink();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Basic Info Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: user.profilePicture != null
                                  ? NetworkImage(user.profilePicture!)
                                  : null,
                              child: user.profilePicture == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DynamicText(
                                    user.name,
                                    style: AppThemes.f20w600,
                                  ),
                                  const SizedBox(height: 4),
                                  DynamicText(
                                    user.email ?? 'No email provided',
                                    style: AppThemes.f14w400.copyWith(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  DynamicText(
                                    user.phoneNumber ?? 'No phone provided',
                                    style: AppThemes.f14w400.copyWith(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// Status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: user.isActive
                                    ? const Color(0xFFDBFCE7)
                                    : const Color(0xFFFFE2E2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: DynamicText(
                                user.isActive ? 'Active' : 'Blocked',
                                style: AppThemes.f14w500.copyWith(
                                  color: user.isActive
                                      ? const Color(0xFF1E8E4E)
                                      : const Color(0xFFF93939),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        /// Stats
                        if (user.stats != null) ...[
                          DynamicText('Statistics', style: AppThemes.f16w600),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: 'Total Listings',
                                  value: user.stats!.totalListings.toString(),
                                  icon: Icons.list_alt,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StatCard(
                                  title: 'Total Transactions',
                                  value: user.stats!.totalTransactions
                                      .toString(),
                                  icon: Icons.sync_alt,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StatCard(
                                  title: 'Total Spend',
                                  value: user.stats!.totalSpend.toStringAsFixed(
                                    2,
                                  ),
                                  icon: Icons.attach_money,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],

                        /// Store Details
                        if (user.isStore && user.storeDetails != null) ...[
                          DynamicText(
                            'Store Details',
                            style: AppThemes.f16w600,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE1E1E1),
                              ),
                            ),
                            child: Column(
                              children: [
                                _InfoRow(
                                  label: 'Store Name',
                                  value: user.storeDetails!.name,
                                ),
                                const SizedBox(height: 8),
                                _InfoRow(
                                  label: 'Store Status',
                                  value: user.storeDetails!.status
                                      .toUpperCase(),
                                ),
                                const SizedBox(height: 8),
                                _InfoRow(
                                  label: 'Created At',
                                  value: _formatDate(
                                    user.storeDetails!.createdAt,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        /// Additional Info
                        DynamicText('Account Info', style: AppThemes.f16w600),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE1E1E1)),
                          ),
                          child: Column(
                            children: [
                              _InfoRow(
                                label: 'Provider',
                                value: user.provider ?? 'N/A',
                              ),
                              const SizedBox(height: 8),
                              _InfoRow(
                                label: 'Role',
                                value: user.isStore
                                    ? 'Store Owner'
                                    : 'Standard User',
                              ),
                              const SizedBox(height: 8),
                              _InfoRow(
                                label: 'Joined',
                                value: _formatDate(user.createdAt),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy h:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 24),
          const SizedBox(height: 12),
          DynamicText(
            value,
            style: AppThemes.f20w600.copyWith(color: AppColors.primaryColor),
          ),
          const SizedBox(height: 4),
          DynamicText(
            title,
            style: AppThemes.f12w400.copyWith(color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DynamicText(
          label,
          style: AppThemes.f14w400.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DynamicText(
            value,
            style: AppThemes.f14w500,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
