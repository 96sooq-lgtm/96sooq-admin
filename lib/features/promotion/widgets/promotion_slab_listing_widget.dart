import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:flutter/material.dart';

class PromotionSlabListingWidget extends StatelessWidget {
  const PromotionSlabListingWidget({
    super.key,
    required this.name,
    required this.price,
    required this.duration,
    required this.type,
    required this.isBestValue,
    required this.targetAudienceDisplay,
    required this.onEdit,
    required this.onDelete,
  });
  final String name;
  final String price;
  final String duration;
  final String type;
  final bool isBestValue;
  final String targetAudienceDisplay;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            flex: 3,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DynamicText(name, style: AppThemes.f20w300),
                if (isBestValue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: DynamicText(
                      'Best Value',
                      style: AppThemes.f16w500.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: DynamicText(price, style: AppThemes.f20w300)),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: DynamicText(duration, style: AppThemes.f20w300),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: DynamicText(type, style: AppThemes.f20w300)),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: DynamicText(
                targetAudienceDisplay,
                style: AppThemes.f20w300,
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Center(
              child: PopupMenuButton<String>(
                color: Colors.white,
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                    return;
                  }
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                  PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                ],
                icon: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
