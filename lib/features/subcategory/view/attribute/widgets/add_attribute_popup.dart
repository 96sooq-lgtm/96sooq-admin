import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:_96sooq_admin/features/subcategory/view/attribute/models/attribute_ui_models.dart';
import 'package:_96sooq_admin/features/subcategory/view/attribute/widgets/attribute_option_item.dart';
import 'package:_96sooq_admin/features/subcategory/view/attribute/widgets/attribute_type_selector.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_bloc.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_event.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_state.dart';
import 'package:_96sooq_admin/core/bloc/language/translation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddAttributePopup extends StatefulWidget {
  const AddAttributePopup({
    super.key,
    required this.subcategoryId,
    this.initialValue,
    this.isEditable = false,
    this.allAttributes = const [],
  });

  final String subcategoryId;
  final AttributeUiItem? initialValue;
  final bool isEditable;
  final List<AttributeUiItem> allAttributes;

  @override
  State<AddAttributePopup> createState() => _AddAttributePopupState();
}

class _AddAttributePopupState extends State<AddAttributePopup> {
  late final TextEditingController _nameEnController;
  late final TextEditingController _nameArController;
  late final TextEditingController _optionController;
  late AttributeType _selectedType;
  late bool _isActive;
  late List<String> _options;

  // Track if we've successfully created this attribute, so subsequent saves are updates
  AttributeUiItem? _currentValue;

  bool _isLoading = false;

  bool get _isEditMode => _currentValue != null;
  bool get _isFieldsEnabled => !_isEditMode || widget.isEditable;
  bool get _showsOptions => _selectedType != AttributeType.textField;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _initializeFields(_currentValue);
    _optionController = TextEditingController();
  }

  void _initializeFields(AttributeUiItem? item) {
    _nameEnController = TextEditingController(text: item?.nameEn ?? '');
    _nameArController = TextEditingController(text: item?.nameAr ?? '');
    _selectedType = item?.type ?? AttributeType.dropdown;
    _isActive = item?.isActive ?? true;
    _options = List<String>.from(item?.options ?? const <String>[]);
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameArController.dispose();
    _optionController.dispose();
    super.dispose();
  }

  void _addOption() {
    final option = _optionController.text.trim();
    if (option.isEmpty) return;
    setState(() {
      _options.add(option);
      _optionController.clear();
    });
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
  }

  void _submit() {
    final nameEn = _nameEnController.text.trim();
    final nameAr = _nameArController.text.trim();

    if (nameEn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attribute English name is required')),
      );
      return;
    }
    if (_showsOptions && _options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one option')),
      );
      return;
    }

    final String typeStr = _selectedType == AttributeType.dropdown
        ? 'dropdown'
        : _selectedType == AttributeType.radio
        ? 'radio'
        : 'text_field';

    if (_isEditMode && widget.isEditable) {
      // Build the full attributes array with this attribute updated
      final updatedAttributes = widget.allAttributes.map((attr) {
        if (attr.key == _currentValue!.key) {
          return {
            'name': nameEn.toLowerCase().replaceAll(' ', '_'),
            'label_en': nameEn,
            'type': typeStr,
            if (nameAr.isNotEmpty) 'label_ar': nameAr,
            if (_showsOptions) 'options': _options.toList(),
          };
        }
        return {
          'name': attr.key,
          'label_en': attr.nameEn,
          'type': attr.rawType.isNotEmpty ? attr.rawType : 'text_field',
          if (attr.nameAr.isNotEmpty) 'label_ar': attr.nameAr,
          if (attr.options.isNotEmpty) 'options': attr.options,
        };
      }).toList();

      setState(() => _isLoading = true);
      context.read<SubcategoryBloc>().add(
        EditCategoryAttributes(widget.subcategoryId, updatedAttributes),
      );
    } else if (_isEditMode) {
      // Patch case (diff fields)
      final payload = <String, dynamic>{};

      final currentKey = _currentValue!.key.isNotEmpty
          ? _currentValue!.key
          : _currentValue!.nameEn;

      if (nameEn != _currentValue!.nameEn) {
        payload['label_en'] = nameEn;
        // Optionally update the key name if backend expects it
        payload['name'] = nameEn.toLowerCase().replaceAll(' ', '_');
      }
      if (nameAr != _currentValue!.nameAr) {
        payload['label_ar'] = nameAr;
      }
      if (_selectedType != _currentValue!.type) {
        payload['type'] = typeStr;
      }
      if (_isActive != _currentValue!.isActive) {
        payload['required'] = _isActive;
      }

      // Compare options strictly if they exist
      final bool optionsChanged =
          _options.length != _currentValue!.options.length ||
          _options.asMap().entries.any(
            (e) => e.value != _currentValue!.options[e.key],
          );

      if (optionsChanged) {
        payload['options'] = _options.isEmpty ? [] : _options.toList();
      }

      if (payload.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No changes to update')));
        return;
      }

      setState(() => _isLoading = true);
      context.read<SubcategoryBloc>().add(
        UpdateSubcategoryAttribute(widget.subcategoryId, currentKey, payload),
      );
    } else {
      // Create case
      final payload = {
        "name": nameEn.toLowerCase().replaceAll(' ', '_'),
        "label_en": nameEn,
        "label_ar": nameAr,
        "type": typeStr,
        "options": _options.isEmpty ? [] : _options.toList(),
        "required": _isActive,
        "status": "active",
      };

      setState(() => _isLoading = true);
      context.read<SubcategoryBloc>().add(
        CreateSubcategoryAttribute(widget.subcategoryId, payload),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final panelWidth = width > 1400 ? 560.0 : 500.0;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: BlocConsumer<SubcategoryBloc, SubcategoryState>(
          listener: (context, state) {
            if (state is SubcategorySuccess && _isLoading) {
              setState(() {
                _isLoading = false;

                // If it was a create, shift over to Edit mode next
                if (!_isEditMode) {
                  _currentValue = AttributeUiItem(
                    nameEn: _nameEnController.text.trim(),
                    nameAr: _nameArController.text.trim(),
                    rawType: _selectedType == AttributeType.dropdown
                        ? 'dropdown'
                        : _selectedType == AttributeType.radio
                        ? 'radio'
                        : 'text_field',
                    type: _selectedType,
                    isActive: _isActive,
                    options: List.from(_options),
                    key: _nameEnController.text.trim().toLowerCase().replaceAll(
                      ' ',
                      '_',
                    ),
                  );
                } else {
                  // Update the stored current value with new changes, so further edits diff correctly
                  _currentValue = AttributeUiItem(
                    nameEn: _nameEnController.text.trim(),
                    nameAr: _nameArController.text.trim(),
                    rawType: _selectedType == AttributeType.dropdown
                        ? 'dropdown'
                        : _selectedType == AttributeType.radio
                        ? 'radio'
                        : 'text_field',
                    type: _selectedType,
                    isActive: _isActive,
                    options: List.from(_options),
                    key: _currentValue!.key,
                  );
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Attribute saved successfully!')),
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
              width: panelWidth,
              margin: const EdgeInsets.only(right: 24, top: 24, bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        DynamicText(
                          _isEditMode
                              ? (widget.isEditable
                                    ? 'Edit Attribute'
                                    : 'Added Attribute')
                              : 'Add Attributes',
                          style: AppThemes.f24w500,
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE1E1E1)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DynamicText(
                            'Attribute Name',
                            style: AppThemes.f24w500,
                          ),
                          const SizedBox(height: 8),
                          Text('English', style: AppThemes.f18w400),
                          CustomTextFormField(
                            labelText: 'Fuel',
                            controller: _nameEnController,
                            enabled: _isFieldsEnabled,
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text('العربية', style: AppThemes.f16w400),
                          ),
                          CustomTextFormField(
                            labelText: '',
                            controller: _nameArController,
                            enabled: _isFieldsEnabled,
                            suffixIcon: const Icon(Icons.translate),
                            onSuffixTap: () async {
                              final text = _nameEnController.text.trim();
                              if (text.isNotEmpty) {
                                final translated =
                                    await TranslationService.translate(
                                      text,
                                      'ar',
                                    );
                                if (!mounted) return;
                                setState(() {
                                  _nameArController.text = translated;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          DynamicText(
                            'Attribute types',
                            style: AppThemes.f18w400,
                          ),
                          const SizedBox(height: 8),
                          AttributeTypeSelector(
                            selectedType: _selectedType,
                            onTypeChanged: (value) {
                              setState(() {
                                _isFieldsEnabled
                                    ? _selectedType = value
                                    : SizedBox();
                              });
                            },
                          ),
                          if (_showsOptions) ...[
                            _isFieldsEnabled
                                ? const SizedBox(height: 14)
                                : SizedBox(),
                            _isFieldsEnabled
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextFormField(
                                          labelText: 'Option value',
                                          controller: _optionController,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 154,
                                        child: CustomButton(
                                          text: '+ Add',
                                          onPressed: _addOption,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                            if (_options.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ...List.generate(
                                _options.length,
                                (index) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == _options.length - 1
                                        ? 0
                                        : 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: AttributeOptionItem(
                                          value: _options[index],
                                        ),
                                      ),
                                      _isFieldsEnabled
                                          ? IconButton(
                                              onPressed: () =>
                                                  _removeOption(index),
                                              icon: const Icon(
                                                Icons.close,
                                                size: 18,
                                                color: Color(0xFF6B7280),
                                              ),
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                          const SizedBox(height: 16),
                          _isFieldsEnabled
                              ? Text('Status', style: AppThemes.f18w400)
                              : SizedBox(),
                          _isFieldsEnabled
                              ? const SizedBox(height: 6)
                              : SizedBox(),
                          _isFieldsEnabled
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFEFEF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<bool>(
                                      value: _isActive,
                                      isExpanded: true,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: true,
                                          child: Text('Active'),
                                        ),
                                        DropdownMenuItem(
                                          value: false,
                                          child: Text('Inactive'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(() {
                                          _isActive = value;
                                        });
                                      },
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ),
                  _isFieldsEnabled
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => Navigator.of(context).pop(),
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
                                    child: Text(
                                      'Cancel',
                                      style: AppThemes.f20w400,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: CustomButton(
                                  text: _isEditMode ? 'Update' : 'Create',
                                  onPressed: _submit,
                                  color: AppColors.primaryColor,
                                  isLoading: _isLoading,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
