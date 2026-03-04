import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:flutter/material.dart';

class TermsAndConditionViewMobile extends StatefulWidget {
  const TermsAndConditionViewMobile({super.key});

  @override
  State<TermsAndConditionViewMobile> createState() =>
      _TermsAndConditionViewMobileState();
}

class _TermsAndConditionViewMobileState
    extends State<TermsAndConditionViewMobile> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  DynamicText("Terms & Conditions", style: AppThemes.f20w600),
                  const SizedBox(height: 6),
                  DynamicText(
                    "Edit and manage your 96 sooq terms and conditions",
                    style: AppThemes.f14w400,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE1E1E1)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DynamicText(
                                "Last updated : 21, 2025",
                                style: AppThemes.f14w400,
                              ),
                              const SizedBox(height: 12),
                              CustomButton(
                                text: isEditing ? "Publish" : "Edit",
                                onPressed: () {
                                  setState(() => isEditing = !isEditing);
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE1E1E1)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),
                            child: TextFormField(
                              initialValue:
                                  "Welcome to our 96 sooq\n"
                                  "These Terms and Conditions ('Terms') govern your use of our marketplace platform.\n"
                                  "1. Acceptance of Terms\n"
                                  "By accessing and using this marketplace, you accept and agree to be bound by these Terms and our Privacy Policy.\n"
                                  "2. User Accounts\n"
                                  "- You must be at least 18 years old to create an account\n"
                                  "- You are responsible for maintaining the confidentiality of your account\n"
                                  "- You agree to provide accurate and complete information\n"
                                  "3. Seller Responsibilities\n"
                                  "- Sellers must provide accurate product descriptions\n"
                                  "- All products must comply with applicable laws\n"
                                  "- Sellers are responsible for order fulfillment and customer service",
                              readOnly: !isEditing,
                              maxLines: null,
                              style: AppThemes.f16w400,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
