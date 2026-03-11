import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_state.dart';
import 'package:_96sooq_admin/core/bloc/language/translation_service.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_bloc.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_event.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_state.dart';
import 'package:_96sooq_admin/features/subcategory/model/subcategory_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttributeMobileView extends StatefulWidget {
  final SubcategoryModel subcategory;

  const AttributeMobileView({super.key, required this.subcategory});

  @override
  State<AttributeMobileView> createState() => _AttributeMobileViewState();
}

class _AttributeMobileViewState extends State<AttributeMobileView> {
  final TextEditingController searchController = TextEditingController();
  late List<SubcategoryAttributeSchema> _attributes;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _attributes = List.from(widget.subcategory.attributesSchema ?? []);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String _label(TranslationState state, String en, String ar) {
    return state.isRTL ? ar : en;
  }

  void _saveAttributes(TranslationState langState) {
    setState(() {
      isSubmitting = true;
    });

    final updatedModel = SubcategoryModel(
      id: widget.subcategory.id,
      nameEn: widget.subcategory.nameEn,
      nameAr: widget.subcategory.nameAr,
      parentId: widget.subcategory.parentId,
      imageUrl: widget.subcategory.imageUrl,
      isActive: widget.subcategory.isActive,
      attributesSchema: _attributes,
    );

    context.read<SubcategoryBloc>().add(
      UpdateSubcategory(widget.subcategory.id, updatedModel),
    );
  }

  void _openDeleteAttributeDialog(TranslationState langState, int index) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: DynamicText(
            _label(langState, "Remove Attribute", "إزالة السمة"),
            style: AppThemes.f18w600,
          ),
          content: DynamicText(
            _label(
              langState,
              "Are you sure you want to remove this attribute?",
              "هل أنت متأكد من رغبتك في إزالة هذه السمة؟",
            ),
            style: AppThemes.f14w400,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: DynamicText(
                _label(langState, "Cancel", "إلغاء"),
                style: AppThemes.f14w600.copyWith(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  _attributes.removeAt(index);
                });
                Navigator.pop(dialogContext);
                _saveAttributes(langState);
              },
              child: DynamicText(
                _label(langState, "Remove", "إزالة"),
                style: AppThemes.f14w600.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openAddAttributePopup(TranslationState langState, {int? editIndex}) {
    final isEditMode = editIndex != null;
    final initialValue = isEditMode ? _attributes[editIndex] : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: _AddAttributeForm(
                langState: langState,
                subcategory: widget.subcategory,
                initialValue: initialValue,
              ),
            ),
          ),
        );
      },
    );
  }

  void _openEditAttributePopup(TranslationState langState, int index) {
    final initialValue = _attributes[index];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: _AddAttributeForm(
                langState: langState,
                subcategory: widget.subcategory,
                initialValue: initialValue,
                isEditable: true,
                allAttributes: _attributes,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, langState) {
        return BlocListener<SubcategoryBloc, SubcategoryState>(
          listener: (context, state) {
            if (!isSubmitting) return;

            if (state is SubcategoryLoaded) {
              setState(() {
                isSubmitting = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _label(langState, "Attributes updated", "تم تحديث السمات"),
                  ),
                ),
              );
            }

            if (state is SubcategoryError) {
              setState(() {
                isSubmitting = false;
              });
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: BlocBuilder<SubcategoryBloc, SubcategoryState>(
            builder: (context, subcatState) {
              if (subcatState is SubcategoryLoaded) {
                try {
                  final updatedSubcat = subcatState.subcategories.firstWhere(
                    (s) => s.id == widget.subcategory.id,
                  );
                  _attributes = List.from(updatedSubcat.attributesSchema ?? []);
                } catch (_) {
                  // Fallback to initial if not found
                }
              }

              return Scaffold(
                backgroundColor: AppColors.scaffoldColor,
                appBar: AppBar(
                  backgroundColor: AppColors.scaffoldColor,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.black),
                  title: DynamicText(
                    _label(langState, "Attributes", "السمات"),
                    style: AppThemes.f18w600,
                  ),
                  centerTitle: true,
                ),
                body: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                DynamicText(
                                  _label(
                                    langState,
                                    "Subcategory:",
                                    "التصنيف الفرعي:",
                                  ),
                                  style: AppThemes.f14w600,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DynamicText(
                                    langState.isRTL
                                        ? widget.subcategory.nameAr
                                        : widget.subcategory.nameEn,
                                    style: AppThemes.f14w400.copyWith(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE1E1E1),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        CustomTextFormField(
                                          controller: searchController,
                                          onChanged: (_) {
                                            setState(() {});
                                          },
                                          labelText: _label(
                                            langState,
                                            "Search Attributes..",
                                            "ابحث عن السمات",
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.search,
                                            color: Color(0xFF99A1Af),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: CustomButton(
                                            text: _label(
                                              langState,
                                              "+ Add Attribute",
                                              "+ إضافة سمة",
                                            ),
                                            color: Colors.black,
                                            isLoading: isSubmitting,
                                            onPressed: () {
                                              _openAddAttributePopup(langState);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color(0xFFE1E1E1),
                                        ),
                                      ),
                                    ),
                                    padding: const EdgeInsets.only(
                                      bottom: 12,
                                      top: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 16),
                                        Expanded(
                                          flex: 2,
                                          child: DynamicText(
                                            _label(langState, 'Name', 'الاسم'),
                                            style: AppThemes.f14w600,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: DynamicText(
                                              _label(
                                                langState,
                                                'Type',
                                                'النوع',
                                              ),
                                              style: AppThemes.f14w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Center(
                                            child: DynamicText(
                                              _label(
                                                langState,
                                                'Actions',
                                                'إجراءات',
                                              ),
                                              style: AppThemes.f14w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                      ],
                                    ),
                                  ),
                                  Builder(
                                    builder: (context) {
                                      final query = searchController.text
                                          .trim()
                                          .toLowerCase();
                                      final filteredAttributes = _attributes
                                          .where((attr) {
                                            if (query.isEmpty) return true;
                                            return (attr.labelEn)
                                                    .toLowerCase()
                                                    .contains(query) ||
                                                (attr.labelAr)
                                                    .toLowerCase()
                                                    .contains(query);
                                          })
                                          .toList();

                                      if (filteredAttributes.isEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: DynamicText(
                                            _label(
                                              langState,
                                              "No attributes present",
                                              "لا توجد سمات",
                                            ),
                                          ),
                                        );
                                      }
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: filteredAttributes.length,
                                        itemBuilder: (context, index) {
                                          final attr =
                                              filteredAttributes[index];
                                          // Find correct index in original list for editing/deleting
                                          final originalIndex = _attributes
                                              .indexOf(attr);
                                          return _buildMobileAttributeRow(
                                            attr,
                                            langState,
                                            langState.isRTL,
                                            originalIndex,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 10),
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
          ),
        );
      },
    );
  }

  Widget _buildMobileAttributeRow(
    SubcategoryAttributeSchema item,
    TranslationState langState,
    bool isRTL,
    int index,
  ) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEFEFEF))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DynamicText(
              item.labelAr.isNotEmpty
                  ? '${item.labelEn} | ${item.labelAr}'
                  : item.labelEn,
              style: AppThemes.f14w400,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
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
                  item.type.toUpperCase(),
                  style: AppThemes.f12w500.copyWith(
                    color: const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () =>
                      _openAddAttributePopup(langState, editIndex: index),
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
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _openEditAttributePopup(langState, index),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _openDeleteAttributeDialog(langState, index),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
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

class _AddAttributeForm extends StatefulWidget {
  final TranslationState langState;
  final SubcategoryModel subcategory;
  final SubcategoryAttributeSchema? initialValue;
  final bool isEditable;
  final List<SubcategoryAttributeSchema> allAttributes;

  const _AddAttributeForm({
    required this.langState,
    required this.subcategory,
    this.initialValue,
    this.isEditable = false,
    this.allAttributes = const [],
  });

  @override
  State<_AddAttributeForm> createState() => _AddAttributeFormState();
}

class _AddAttributeFormState extends State<_AddAttributeForm> {
  late final TextEditingController nameEnController;
  late final TextEditingController nameArController;
  late final TextEditingController optionController;
  late final TextEditingController optionArController;
  late String type;
  late bool isRequired;
  late List<String> options;
  late List<String> optionsAr;

  bool _isLoading = false;
  SubcategoryAttributeSchema? _currentValue;

  String _label(String en, String ar) {
    return widget.langState.isRTL ? ar : en;
  }

  bool get _isEditMode => _currentValue != null;
  bool get _isFieldsEnabled => !_isEditMode || widget.isEditable;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _initializeFields(_currentValue);
    optionController = TextEditingController();
    optionArController = TextEditingController();
  }

  void _initializeFields(SubcategoryAttributeSchema? value) {
    nameEnController = TextEditingController(text: value?.labelEn ?? '');
    nameArController = TextEditingController(text: value?.labelAr ?? '');
    type = value?.type ?? 'select';
    if (type != 'radio' &&
        type != 'text' &&
        type != 'select' &&
        type != 'dropdown') {
      type =
          'select'; // select is mapped to dropdown in model usually, keeping compatibility
    }
    isRequired = value?.required ?? true;
    options = List.from(value?.options ?? []);
    optionsAr = List.from(value?.optionsAr ?? []);
  }

  @override
  void dispose() {
    nameEnController.dispose();
    nameArController.dispose();
    optionController.dispose();
    optionArController.dispose();
    super.dispose();
  }

  void _addOptionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteTextColor,
          title: Text(_label("Add Option", "إضافة خيار")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormField(
                controller: optionController,
                labelText: _label("Option (English)", "الخيار (بالإنجليزية)"),
              ),
              const SizedBox(height: 12),
              CustomTextFormField(
                controller: optionArController,
                labelText: _label("Option (Arabic)", "الخيار (بالعربية)"),
                suffixIcon: const Icon(Icons.translate),
                onSuffixTap: () async {
                  final text = optionController.text.trim();
                  if (text.isNotEmpty) {
                    final translated = await TranslationService.translate(
                      text,
                      'ar',
                    );
                    if (!mounted) return;
                    setState(() {
                      optionArController.text = translated;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_label("Cancel", "إلغاء")),
            ),
            TextButton(
              onPressed: () {
                final enVal = optionController.text.trim();
                final arVal = optionArController.text.trim();
                if (enVal.isNotEmpty) {
                  setState(() {
                    options.add(enVal);
                    optionsAr.add(arVal);
                    optionController.clear();
                    optionArController.clear();
                  });
                }
                Navigator.pop(context);
              },
              child: Text(_label("Add", "إضافة")),
            ),
          ],
        );
      },
    );
  }

  // Widget _buildShimmerOverlay(Widget child) {
  //   if (!_isLoading) return child;

  //   return Stack(
  //     children: [
  //       child,
  //       Positioned.fill(
  //         child: Container(
  //           color: Colors.white.withValues(alpha: 0.8),
  //           child: Shimmer.fromColors(
  //             baseColor: Colors.grey[300]!,
  //             highlightColor: Colors.grey[100]!,
  //             child: Container(
  //               color: Colors.white,
  //               margin: const EdgeInsets.all(24),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  void _submit() {
    final nameEn = nameEnController.text.trim();
    final nameAr = nameArController.text.trim();

    if (nameEn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attribute English name is required')),
      );
      return;
    }
    bool showsOptions =
        type == 'select' || type == 'radio' || type == 'dropdown';
    if (showsOptions && options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one option')),
      );
      return;
    }

    final String typeStr = type == 'select' ? 'dropdown' : type;

    if (_isEditMode && widget.isEditable) {
      // Build the full attributes array with this attribute updated
      final updatedAttributes = widget.allAttributes.map((attr) {
        if (attr.labelEn == _currentValue!.labelEn) {
          return <String, dynamic>{
            'name': nameEn.toLowerCase().replaceAll(' ', '_'),
            'label_en': nameEn,
            'type': typeStr,
            if (nameAr.isNotEmpty) 'label_ar': nameAr,
            if (showsOptions) 'options': options.toList(),
            if (showsOptions && optionsAr.isNotEmpty)
              'options_ar': optionsAr.toList(),
          };
        }
        return <String, dynamic>{
          'name': attr.labelEn.toLowerCase().replaceAll(' ', '_'),
          'label_en': attr.labelEn,
          'type': attr.type,
          if (attr.labelAr.isNotEmpty) 'label_ar': attr.labelAr,
          if (attr.options != null && attr.options!.isNotEmpty)
            'options': attr.options,
          if (attr.optionsAr != null && attr.optionsAr!.isNotEmpty)
            'options_ar': attr.optionsAr,
        };
      }).toList();

      setState(() => _isLoading = true);
      context.read<SubcategoryBloc>().add(
        EditCategoryAttributes(widget.subcategory.id, updatedAttributes),
      );
    } else if (_isEditMode) {
      final payload = <String, dynamic>{};

      final currentKey = _currentValue!.labelEn.isNotEmpty
          ? _currentValue!.labelEn
          : _currentValue!.labelAr;

      if (nameEn != _currentValue!.labelEn) {
        payload['label_en'] = nameEn;
        payload['name'] = nameEn.toLowerCase().replaceAll(' ', '_');
      }
      if (nameAr != _currentValue!.labelAr) {
        payload['label_ar'] = nameAr;
      }
      if (typeStr != _currentValue!.type) {
        payload['type'] = typeStr;
      }
      if (isRequired != _currentValue!.required) {
        payload['required'] = isRequired;
      }

      final bool optionsChanged =
          options.length != _currentValue!.options!.length ||
          options.asMap().entries.any(
            (e) => e.value != _currentValue!.options![e.key],
          );

      if (optionsChanged) {
        payload['options'] = options.isEmpty ? [] : options.toList();
      }

      final bool optionsArChanged =
          _currentValue!.optionsAr == null ||
          optionsAr.length != _currentValue!.optionsAr!.length ||
          optionsAr.asMap().entries.any(
            (e) => e.value != _currentValue!.optionsAr![e.key],
          );

      if (optionsArChanged) {
        payload['options_ar'] = optionsAr.isEmpty ? [] : optionsAr.toList();
      }

      if (payload.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No changes to update')));
        return;
      }

      setState(() => _isLoading = true);
      context.read<SubcategoryBloc>().add(
        UpdateSubcategoryAttribute(widget.subcategory.id, currentKey, payload),
      );
    } else {
      final payload = {
        "name": nameEn.toLowerCase().replaceAll(' ', '_'),
        "label_en": nameEn,
        "label_ar": nameAr,
        "type": typeStr,
        "options": options.isEmpty ? [] : options.toList(),
        "options_ar": optionsAr.isEmpty ? [] : optionsAr.toList(),
        "required": isRequired,
        "status": "active",
      };

      setState(() => _isLoading = true);
      context.read<SubcategoryBloc>().add(
        CreateSubcategoryAttribute(widget.subcategory.id, payload),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showsOptions =
        type == 'select' || type == 'radio' || type == 'dropdown';

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BlocConsumer<SubcategoryBloc, SubcategoryState>(
          listener: (context, state) {
            if (state is SubcategorySuccess && _isLoading) {
              setState(() {
                _isLoading = false;

                final updatedType = type == 'select' ? 'dropdown' : type;
                if (!_isEditMode) {
                  _currentValue = SubcategoryAttributeSchema(
                    key: nameEnController.text.trim().toLowerCase().replaceAll(
                      ' ',
                      '_',
                    ),
                    labelEn: nameEnController.text.trim(),
                    labelAr: nameArController.text.trim(),
                    type: updatedType,
                    required: isRequired,
                    status: 'active',
                    options: List.from(options),
                    optionsAr: List.from(optionsAr),
                  );
                } else {
                  _currentValue = SubcategoryAttributeSchema(
                    key: _currentValue!.key,
                    labelEn: nameEnController.text.trim(),
                    labelAr: nameArController.text.trim(),
                    type: updatedType,
                    required: isRequired,
                    status: _currentValue!.status,
                    options: List.from(options),
                    optionsAr: List.from(optionsAr),
                  );
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _label("Attributes updated", "تم تحديث السمات"),
                  ),
                ),
              );

              if (widget.isEditable) {
                Navigator.of(context).pop();
              }
            } else if (state is SubcategoryError && _isLoading) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DynamicText(
                        _isEditMode
                            ? (widget.isEditable
                                  ? _label("Edit Attribute", "تعديل السمة")
                                  : _label(
                                      "Added Attributes",
                                      "السمات المضافة",
                                    ))
                            : _label("Add Attributes", "إضافة سمات"),
                        style: AppThemes.f18w600,
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFEFEFEF), height: 1),
                  const SizedBox(height: 20),
                  DynamicText(
                    _label("Attribute Name", "اسم السمة"),
                    style: AppThemes.f16w600,
                  ),
                  const SizedBox(height: 12),
                  DynamicText(
                    _label("English", "انجليزي"),
                    style: AppThemes.f14w400.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: nameEnController,
                    labelText: 'Fuel',
                    enabled: _isFieldsEnabled,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: DynamicText(
                      "العَرَبِيَّةُ",
                      style: AppThemes.f14w400.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: nameArController,
                    labelText: '',
                    suffixIcon: const Icon(Icons.translate),
                    enabled: _isFieldsEnabled,
                    onSuffixTap: () async {
                      final text = nameEnController.text.trim();
                      if (text.isNotEmpty) {
                        final translated = await TranslationService.translate(
                          text,
                          'ar',
                        );
                        if (!mounted) return;
                        setState(() {
                          nameArController.text = translated;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  DynamicText(
                    _label("Attribute types", "نوع السمة"),
                    style: AppThemes.f14w400.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTypeSelector('Radio button', 'radio'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTypeSelector('Dropdown', 'select')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildTypeSelector('Text field', 'text')),
                    ],
                  ),
                  if (showsOptions) ...[
                    _isFieldsEnabled ? const SizedBox(height: 24) : SizedBox(),
                    _isFieldsEnabled
                        ? CustomButton(
                            text: "+ Value",
                            color: Colors.black,
                            onPressed: _addOptionDialog,
                          )
                        : SizedBox(),
                    const SizedBox(height: 16),
                    ...options.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFEFEFEF),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: DynamicText(
                                  entry.key < optionsAr.length &&
                                          optionsAr[entry.key].isNotEmpty
                                      ? '${entry.value} | ${optionsAr[entry.key]}'
                                      : entry.value,
                                  style: AppThemes.f14w400,
                                ),
                              ),
                              _isFieldsEnabled
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          options.removeAt(entry.key);
                                          if (entry.key < optionsAr.length) {
                                            optionsAr.removeAt(entry.key);
                                          }
                                        });
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        size: 18,
                                        color: Colors.black54,
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 20),
                  _isFieldsEnabled
                      ? DynamicText(
                          _label("Status", "الحالة"),
                          style: AppThemes.f14w400.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        )
                      : SizedBox(),
                  _isFieldsEnabled ? const SizedBox(height: 8) : SizedBox(),
                  _isFieldsEnabled
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFEFEFEF),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<bool>(
                              value: isRequired,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: [
                                DropdownMenuItem(
                                  value: true,
                                  child: DynamicText(_label("Active", "نشط")),
                                ),
                                DropdownMenuItem(
                                  value: false,
                                  child: DynamicText(
                                    _label("Inactive", "غير نشط"),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    isRequired = value;
                                  });
                                }
                              },
                            ),
                          ),
                        )
                      : SizedBox(),
                  const SizedBox(height: 32),
                  _isFieldsEnabled
                      ? Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE1E1E1),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: DynamicText(
                                    'Cancel',
                                    style: AppThemes.f16w400,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: CustomButton(
                                text: _label(
                                  _isEditMode ? "Update" : "Add",
                                  _isEditMode ? "تحديث" : "إضافة",
                                ),
                                isLoading: _isLoading,
                                onPressed: _submit,
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypeSelector(String label, String value) {
    // Treat 'dropdown' as 'select' for the UI match
    final bool isSelected =
        type == value || (type == 'dropdown' && value == 'select');
    return GestureDetector(
      onTap: _isFieldsEnabled
          ? () {
              setState(() {
                type = value;
                if (type == 'text') {
                  options.clear();
                }
              });
            }
          : () {},
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFEFEFEF),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: DynamicText(
          label,
          style: AppThemes.f14w500.copyWith(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
