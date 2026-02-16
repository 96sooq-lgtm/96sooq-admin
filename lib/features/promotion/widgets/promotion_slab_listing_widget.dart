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
    required this.onDelete,
  });
  final String name;
  final String price;
  final String duration;
  final String type;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          SizedBox(width: 40),
          Expanded(flex: 2, child: DynamicText(name, style: AppThemes.f20w300)),
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
            child: Center(
              child: DynamicText(type, style: AppThemes.f20w300),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                IconButton(
                  onPressed: onDelete,
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
