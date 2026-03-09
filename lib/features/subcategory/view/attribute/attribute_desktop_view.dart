import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/category/widgets/add_category_popup.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_state.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:_96sooq_admin/features/subcategory/model/subcategory_model.dart';
import 'package:_96sooq_admin/features/subcategory/view/attribute/models/attribute_ui_models.dart';
import 'package:_96sooq_admin/features/subcategory/view/attribute/widgets/add_attribute_popup.dart';
import 'package:_96sooq_admin/features/subcategory/view/attribute/widgets/attribute_table_row.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_bloc.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttributeDesktopView extends StatefulWidget {
  const AttributeDesktopView({super.key, required this.subcategory});

  final SubcategoryModel subcategory;

  @override
  State<AttributeDesktopView> createState() => _AttributeDesktopViewState();
}

class _AttributeDesktopViewState extends State<AttributeDesktopView> {
  late List<AttributeUiItem> _attributes;

  @override
  void initState() {
    super.initState();
    final schema = widget.subcategory.attributesSchema ?? const [];
    _attributes = schema.map(AttributeUiItem.fromSchema).toList();
  }

  void _openAttributePopup({int? editIndex}) {
    final isEditMode = editIndex != null;
    final initialValue = isEditMode ? _attributes[editIndex] : null;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Add attribute',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: AddAttributePopup(
            subcategoryId: widget.subcategory.id,
            initialValue: initialValue,
          ),
        );
      },
    );
  }

  void _openEditAttributePopup(int index) {
    final initialValue = _attributes[index];
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit attribute',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SafeArea(
          child: AddAttributePopup(
            subcategoryId: widget.subcategory.id,
            initialValue: initialValue,
            isEditable: true,
            allAttributes: _attributes,
          ),
        );
      },
    );
  }

  void _deleteAttribute(int index) {
    if (index < 0 || index >= _attributes.length) return;

    final attribute = _attributes[index];
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocListener<SubcategoryBloc, SubcategoryState>(
              listener: (context, state) {
                if (!isDeleting) return;
                if (state is SubcategorySuccess || state is SubcategoryError) {
                  Navigator.pop(dialogContext);
                  setState(() {
                    _attributes.removeAt(index);
                  });
                }
              },
              child: AdminActionDialog(
                title: "Delete Attribute",
                submitText: "Delete",
                submitLoading: isDeleting,
                submitEnabled: !isDeleting,
                submitColor: Colors.black,
                child: DynamicText(
                  'Are you sure you want to delete "${attribute.nameEn}"?',
                  style: AppThemes.f18w400,
                ),
                onSubmit: () {
                  setDialogState(() {
                    isDeleting = true;
                  });

                  final attributeName = attribute.key.isNotEmpty
                      ? attribute.key
                      : attribute.nameEn;

                  context.read<SubcategoryBloc>().add(
                    DeleteSubcategoryAttribute(
                      widget.subcategory.id,
                      attributeName,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<TranslationBloc>().state.isRTL;
    final title = isArabic
        ? widget.subcategory.nameAr
        : widget.subcategory.nameEn;

    return BlocBuilder<SubcategoryBloc, SubcategoryState>(
      builder: (context, subcatState) {
        if (subcatState is SubcategoryLoaded) {
          try {
            final updatedSubcat = subcatState.subcategories.firstWhere(
              (s) => s.id == widget.subcategory.id,
            );
            final schema = updatedSubcat.attributesSchema ?? const [];
            _attributes = schema.map(AttributeUiItem.fromSchema).toList();
          } catch (_) {
            // fallback if not found
          }
        }

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
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Back to Sub Category',
                              style: AppThemes.f16w500,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      DynamicText(title, style: AppThemes.f28w600),
                      const SizedBox(height: 10),
                      DynamicText(
                        'Manage attributes for each sub categories',
                        style: AppThemes.f20w400,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE1E1E1)),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 36,
                                vertical: 36,
                              ),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  SizedBox(
                                    width: 220,
                                    child: CustomButton(
                                      text: '+ Attribute',
                                      onPressed: _openAttributePopup,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 16,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF9FAFB),
                                border: Border(
                                  top: BorderSide(color: Color(0xFFE1E1E1)),
                                  bottom: BorderSide(color: Color(0xFFE1E1E1)),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: DynamicText(
                                      'Attribute Name',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: DynamicText(
                                      'Type',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: DynamicText(
                                      'Status',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: DynamicText(
                                      'Actions',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_attributes.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: DynamicText('No attributes added yet'),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _attributes.length,
                                itemBuilder: (context, index) {
                                  return AttributeTableRow(
                                    attribute: _attributes[index],
                                    onEdit: () =>
                                        _openAttributePopup(editIndex: index),
                                    onEditAttributes: () =>
                                        _openEditAttributePopup(index),
                                    onDelete: () => _deleteAttribute(index),
                                  );
                                },
                              ),
                            const SizedBox(height: 280),
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
      },
    );
  }
}
