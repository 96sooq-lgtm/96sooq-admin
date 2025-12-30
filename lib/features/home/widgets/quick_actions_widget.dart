import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/category/widgets/add_category_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({
    super.key,
    required this.svgPath,
    required this.title,
    this.onTap,
  });

  final String svgPath;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE1E1E1)),
        ),
        child: Row(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            SvgPicture.asset(svgPath),
            const SizedBox(width: 8),
            Text(
              title,
              textAlign: TextAlign.left,
              // overflow: TextOverflow.ellipsis,
              style: AppThemes.f20w500,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionPopupContent {
  static void showAddCategoryDialog(BuildContext context) {
    final categoryNameController = TextEditingController();
    String status = 'Active';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AdminActionDialog(
              title: 'Add Category',
              onSubmit: () {
                debugPrint(categoryNameController.text);
                debugPrint(status);
                Navigator.pop(context);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Name',
                    style: AppThemes.f20w400.copyWith(color: Color(0xFF707070)),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    labelText: "",
                    controller: categoryNameController,
                  ),
                  const SizedBox(height: 8),
                  Text('Status'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFEFEFEF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                      ),
                      helperText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 18,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(14),
                    initialValue: status,
                    items: const [
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'Inactive',
                        child: Text('Inactive'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => status = value!);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showAddSubCategoryDialog(BuildContext context) {
    final categoryNameController = TextEditingController();
    final subCategoryNameController = TextEditingController();

    String status = 'Active';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AdminActionDialog(
              title: 'Add Sub Category',
              onSubmit: () {
                debugPrint(categoryNameController.text);
                debugPrint(status);
                Navigator.pop(context);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Name',
                    style: AppThemes.f20w400.copyWith(color: Color(0xFF707070)),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    labelText: "",
                    controller: categoryNameController,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sub Category Name',
                    style: AppThemes.f20w400.copyWith(color: Color(0xFF707070)),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    labelText: "",
                    controller: subCategoryNameController,
                  ),
                  const SizedBox(height: 8),
                  Text('Status'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFEFEFEF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                      ),
                      helperText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 18,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(14),
                    initialValue: status,
                    items: const [
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'Inactive',
                        child: Text('Inactive'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => status = value!);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
