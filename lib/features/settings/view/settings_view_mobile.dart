import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_event.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsViewMobile extends StatefulWidget {
  const SettingsViewMobile({super.key});

  @override
  State<SettingsViewMobile> createState() => _SettingsViewMobileState();
}

class _SettingsViewMobileState extends State<SettingsViewMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldColor,
        elevation: 0,
        title: const DynamicText("Admin Settings", style: AppThemes.f20w600),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Subtitle
              const DynamicText(
                "Manage your admin preferences",
                style: AppThemes.f16w400,
              ),

              const SizedBox(height: 24),

              /// Settings Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE1E1E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Section Title
                    const DynamicText(
                      "General Settings",
                      style: AppThemes.f18w600,
                    ),

                    const SizedBox(height: 20),

                    /// Language Label
                    DynamicText(
                      "Language",
                      style: AppThemes.f16w400.copyWith(
                        color: const Color(0xFF707070),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// Language Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: context
                          .read<TranslationBloc>()
                          .state
                          .languageCode,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          context.read<TranslationBloc>().add(
                            ChangeLanguage(newValue),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE1E1E1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE1E1E1),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'en',
                          child: DynamicText('English'),
                        ),
                        DropdownMenuItem(
                          value: 'ar',
                          child: DynamicText('Arabic'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
