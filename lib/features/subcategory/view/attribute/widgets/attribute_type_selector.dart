import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/features/subcategory/view/attribute/models/attribute_ui_models.dart';
import 'package:flutter/material.dart';

class AttributeTypeSelector extends StatelessWidget {
  const AttributeTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final AttributeType selectedType;
  final ValueChanged<AttributeType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TypeItem(
            label: 'Radio button',
            selected: selectedType == AttributeType.radio,
            onTap: () => onTypeChanged(AttributeType.radio),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeItem(
            label: 'Dropdown',
            selected: selectedType == AttributeType.dropdown,
            onTap: () => onTypeChanged(AttributeType.dropdown),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TypeItem(
            label: 'Text field',
            selected: selectedType == AttributeType.textField,
            onTap: () => onTypeChanged(AttributeType.textField),
          ),
        ),
      ],
    );
  }
}

class _TypeItem extends StatelessWidget {
  const _TypeItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.black : const Color(0xFFE1E1E1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.black : const Color(0xFFCBD5E1),
                ),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? Colors.black : Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppThemes.f20w400.copyWith(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
