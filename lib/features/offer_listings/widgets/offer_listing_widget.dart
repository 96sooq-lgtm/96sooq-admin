import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart' show AppThemes;
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:flutter/material.dart';

class OfferListingWidget extends StatelessWidget {
  const OfferListingWidget({
    super.key,
    required this.storeName,
    required this.isActive,
  });

  final String storeName;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            flex: 4,
            child: DynamicText(
              storeName,
              style: AppThemes.f20w300,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: _StatusChip(isActive: isActive)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: (value) {
                    // Handle active/inactive change
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'active',
                      child: Text('Active'),
                    ),
                    PopupMenuItem<String>(
                      value: 'inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  icon: const Icon(Icons.edit, color: AppColors.primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;

  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDBFCE7) : const Color(0xFFFFE2E2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: DynamicText(
          isActive ? 'Active' : 'Inactive',
          style: AppThemes.f20w400.copyWith(
            color: isActive ? const Color(0xFF1E8E4E) : const Color(0xFFF93939),
          ),
        ),
      ),
    );
  }
}
