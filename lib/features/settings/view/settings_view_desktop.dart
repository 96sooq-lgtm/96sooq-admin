import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_event.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsViewDesktop extends StatefulWidget {
  const SettingsViewDesktop({super.key});

  @override
  State<SettingsViewDesktop> createState() => _SettingsViewDesktopState();
}

class _SettingsViewDesktopState extends State<SettingsViewDesktop> {
  String value = "en";
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
                  const SizedBox(height: 36),
                  DynamicText("Admin Settings", style: AppThemes.f28w600),
                  const SizedBox(height: 10),
                  DynamicText(
                    "Manage your admin preferences",
                    style: AppThemes.f20w400,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE1E1E1)),
                    ),
                    child: Column(
                      children: [
                        /// Top Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 25,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: .start,
                              crossAxisAlignment: .start,
                              children: [
                                DynamicText(
                                  "General Settings",
                                  style: AppThemes.f24w500,
                                ),
                                SizedBox(height: 18),
                                DynamicText(
                                  "Language",
                                  style: AppThemes.f20w400.copyWith(
                                    color: Color(0xFF707070),
                                  ),
                                ),
                                SizedBox(height: 18),
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
                                  borderRadius: BorderRadius.circular(14),
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE1E1E1),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE1E1E1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF000000),
                                      ),
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
                        ),
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
