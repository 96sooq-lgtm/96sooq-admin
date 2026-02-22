import 'package:_96sooq_admin/constants/themes.dart';
import 'package:flutter/material.dart';

class AttributeOptionItem extends StatelessWidget {
  const AttributeOptionItem({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        border: Border.all(color: const Color(0xFFE1E1E1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(value, style: AppThemes.f20w400.copyWith(fontSize: 16)),
    );
  }
}
