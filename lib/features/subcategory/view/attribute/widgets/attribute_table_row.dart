import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/subcategory/view/attribute/models/attribute_ui_models.dart';
import 'package:flutter/material.dart';

class AttributeTableRow extends StatelessWidget {
  const AttributeTableRow({
    super.key,
    required this.attribute,
    required this.onEdit,
    required this.onDelete,
  });

  final AttributeUiItem attribute;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F1F1))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              attribute.nameEn,
              style: AppThemes.f20w400.copyWith(fontSize: 24),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DynamicText(
                  attribute.typeBadgeLabel,
                  style: AppThemes.f12w500.copyWith(
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: attribute.isActive
                      ? const Color(0xFFDBFCE7)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DynamicText(
                  attribute.isActive ? 'Active' : 'Inactive',
                  style: AppThemes.f16w500.copyWith(
                    color: attribute.isActive
                        ? const Color(0xFF1E8E4E)
                        : const Color(0xFF4B5563),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 50),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                InkWell(
                  onTap: onEdit,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.remove_red_eye_outlined,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(),
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
