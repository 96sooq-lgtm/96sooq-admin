import 'package:_96sooq_admin/constants/themes.dart';
import 'package:flutter/material.dart';

class SubcategoryListWidget extends StatelessWidget {
  final String categoryName;
  final String subCategoryName;
  final String status;
  const SubcategoryListWidget({
    super.key,
    required this.status,
    required this.categoryName,
    required this.subCategoryName,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Active';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          SizedBox(width: 40),
          Expanded(
            flex: 2,
            child: Text(subCategoryName,style: AppThemes.f20w300),
          ),
          Expanded(
            flex: 2,
            child: Text(categoryName,style: AppThemes.f20w300),
          ),
          Expanded(flex: 1, child: _StatusChip(isActive: isActive)),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFF93939),
                  ),
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
        color: isActive ? const Color(0xFFDBFCE7) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          isActive ? 'Active' : 'Inactive',
          style: AppThemes.f20w400.copyWith(
            color: isActive ? const Color(0xFF1E8E4E) : Color(0xFF2A2F3B),
          ),
        ),
      ),
    );
  }
}
