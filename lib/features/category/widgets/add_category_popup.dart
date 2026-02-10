import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:flutter/material.dart';

class AdminActionDialog extends StatelessWidget {
  const AdminActionDialog({
    super.key,
    required this.title,
    required this.child,
    required this.onSubmit,
    this.onCancel,
    this.submitText = 'Add',
    this.width = 420,
    this.submitEnabled = true,
    this.submitLoading = false,
    this.submitColor,
  });

  final String title;
  final Widget child; // 👈 BODY SLOT
  final VoidCallback onSubmit;
  final VoidCallback? onCancel;
  final String submitText;
  final double width;
  final bool submitEnabled;
  final bool submitLoading;
  final Color? submitColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(child: DynamicText(title, style: AppThemes.f28w500)),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xff666666),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xffe1e1e1)),

            /// BODY (CUSTOM CONTENT)
            Padding(padding: const EdgeInsets.all(20), child: child),

            /// FOOTER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.maxFinite,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xffe1e1e1)),
                          color: Colors.white,
                        ),
                        child: Center(child: DynamicText("Cancel")),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      onPressed: submitEnabled ? onSubmit : () {},
                      text: submitText,
                      isLoading: submitLoading,
                      color: submitColor ?? Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
