import 'dart:typed_data';

import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_state.dart';
import 'package:_96sooq_admin/core/bloc/language/translation_service.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_bloc.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_event.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_state.dart';
import 'package:_96sooq_admin/features/auth/bloc/auth_bloc.dart';
import 'package:_96sooq_admin/features/auth/bloc/auth_state.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/category/bloc/category_bloc.dart';
import 'package:_96sooq_admin/features/category/bloc/category_event.dart';
import 'package:_96sooq_admin/features/category/bloc/category_state.dart';
import 'package:_96sooq_admin/features/category/model/category_model.dart';
import 'package:_96sooq_admin/features/category/widgets/add_category_popup.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_bloc.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_event.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_state.dart';
import 'package:_96sooq_admin/features/subcategory/model/subcategory_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:_96sooq_admin/features/subcategory/view/attribute/attribute_mobile_view.dart';

class SubcategoryMobileView extends StatefulWidget {
  const SubcategoryMobileView({super.key});

  @override
  State<SubcategoryMobileView> createState() => _SubcategoryMobileViewState();
}

class _SubcategoryMobileViewState extends State<SubcategoryMobileView> {
  final TextEditingController searchController = TextEditingController();
  bool isSubmittingSubcategory = false;
  String? pendingActionMessage;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<CategoryBloc>().add(LoadCategories());
      context.read<SubcategoryBloc>().add(LoadSubcategories());
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      // Note: load more subcategories is not supported yet by backend block.
      // context.read<SubcategoryBloc>().add(LoadMoreSubcategories());
    }
  }

  String _label(TranslationState state, String en, String ar) {
    return state.isRTL ? ar : en;
  }

  void _openDeleteSubcategoryDialog(
    TranslationState langState,
    SubcategoryModel subcategory,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AdminActionDialog(
          title: _label(langState, "Delete Sub Category", "حذف التصنيف الفرعي"),
          submitText: _label(langState, "Delete", "حذف"),
          child: DynamicText(
            _label(
              langState,
              "Are you sure you want to delete this sub category?",
              "هل أنت متأكد أنك تريد حذف هذا التصنيف الفرعي؟",
            ),
            style: AppThemes.f18w400,
          ),
          onSubmit: () {
            isSubmittingSubcategory = true;
            pendingActionMessage = _label(
              langState,
              "Sub Category deleted successfully",
              "تم حذف التصنيف الفرعي بنجاح",
            );
            context.read<SubcategoryBloc>().add(
              DeleteSubcategory(subcategory.id),
            );
            Navigator.pop(dialogContext);
          },
        );
      },
    );
  }

  void _openAddSubcategoryDialog(TranslationState langState) {
    final nameEnController = TextEditingController();
    final nameArController = TextEditingController();
    CategoryModel? selectedCategory;
    XFile? selectedImage;
    Uint8List? selectedImageBytes;
    bool isActive = true;
    bool isUploading = false;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocListener<S3UploadBloc, S3UploadState>(
              listener: (context, state) {
                if (!isSubmitting) return;

                if (state is S3UploadSuccess) {
                  final model = SubcategoryModel(
                    id: '',
                    nameEn: nameEnController.text.trim(),
                    nameAr: nameArController.text.trim(),
                    parentId: selectedCategory?.id ?? '',
                    imageUrl: state.result.url,
                    isActive: isActive,
                    attributesSchema: null,
                  );
                  context.read<SubcategoryBloc>().add(CreateSubcategory(model));
                }

                if (state is S3UploadFailure) {
                  isSubmitting = false;
                  isSubmittingSubcategory = false;
                  setDialogState(() {
                    isUploading = false;
                  });
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              child: BlocListener<SubcategoryBloc, SubcategoryState>(
                listener: (context, state) {
                  if (!isSubmitting) return;

                  if (state is SubcategoryLoaded) {
                    isSubmitting = false;
                    Navigator.pop(dialogContext);
                  }

                  if (state is SubcategoryError) {
                    isSubmitting = false;
                    isSubmittingSubcategory = false;
                    setDialogState(() {
                      isUploading = false;
                    });
                    ScaffoldMessenger.of(
                      dialogContext,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                child: AdminActionDialog(
                  title: _label(
                    langState,
                    "Add Sub Category",
                    "إضافة تصنيف فرعي",
                  ),
                  submitText: _label(langState, "Add", "إضافة"),
                  submitColor: Colors.black,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (state is CategoryLoaded) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE1E1E1),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<CategoryModel>(
                                  value: selectedCategory,
                                  isExpanded: true,
                                  hint: DynamicText(
                                    _label(langState, "Category", "التصنيف"),
                                    style: AppThemes.f14w400.copyWith(
                                      color: Color(0xFF99A1AF),
                                    ),
                                  ),
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: state.categories.map((category) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: DynamicText(
                                        langState.isRTL
                                            ? category.nameAr
                                            : category.nameEn,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedCategory = value;
                                    });
                                  },
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomTextFormField(
                        controller: nameEnController,
                        labelText: _label(
                          langState,
                          "Category Name",
                          "الاسم بالإنجليزية",
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextFormField(
                        controller: nameArController,
                        labelText: _label(
                          langState,
                          "Name AR",
                          "الاسم بالعربية",
                        ),
                        suffixIcon: const Icon(Icons.translate),
                        onSuffixTap: () async {
                          final nameEn = nameEnController.text.trim();
                          if (nameEn.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _label(
                                    langState,
                                    "Please enter English name first",
                                    "يرجى إدخال الاسم بالإنجليزية أولاً",
                                  ),
                                ),
                              ),
                            );
                            return;
                          }
                          final translated = await TranslationService.translate(
                            nameEn,
                            'ar',
                          );
                          nameArController.text = translated;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE1E1E1),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DynamicText(
                                selectedImage?.name ??
                                    _label(
                                      langState,
                                      "No image selected",
                                      "لم يتم اختيار صورة",
                                    ),
                                style: AppThemes.f16w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: Icon(Icons.image),
                            onPressed: () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (file == null) return;
                              final bytes = await file.readAsBytes();
                              setDialogState(() {
                                selectedImage = file;
                                selectedImageBytes = bytes;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DynamicText(
                        _label(langState, "Status", "الحالة"),
                        style: AppThemes.f14w400.copyWith(
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE1E1E1)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<bool>(
                            value: isActive,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: [
                              DropdownMenuItem(
                                value: true,
                                child: DynamicText(
                                  _label(langState, "Active", "نشط"),
                                ),
                              ),
                              DropdownMenuItem(
                                value: false,
                                child: DynamicText(
                                  _label(langState, "Inactive", "غير نشط"),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  isActive = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      if (isUploading)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                  onSubmit: () {
                    if (selectedCategory == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            _label(
                              langState,
                              "Please select a category",
                              "يرجى اختيار تصنيف",
                            ),
                          ),
                        ),
                      );
                      return;
                    }

                    final nameEn = nameEnController.text.trim();
                    final nameAr = nameArController.text.trim();
                    if (nameEn.isEmpty && nameAr.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            _label(
                              langState,
                              "Please enter a name",
                              "يرجى إدخال اسم",
                            ),
                          ),
                        ),
                      );
                      return;
                    }

                    if (selectedImage == null || selectedImageBytes == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            _label(
                              langState,
                              "Please choose an image",
                              "يرجى اختيار صورة",
                            ),
                          ),
                        ),
                      );
                      return;
                    }

                    isSubmitting = true;
                    isSubmittingSubcategory = true;
                    pendingActionMessage = _label(
                      langState,
                      "Sub Category created successfully",
                      "تم إنشاء التصنيف الفرعي بنجاح",
                    );

                    setDialogState(() {
                      isUploading = true;
                    });

                    context.read<S3UploadBloc>().add(
                      UploadFile(
                        bytes: selectedImageBytes!,
                        filename: selectedImage!.name,
                        folder: "SubCategories",
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      nameEnController.dispose();
      nameArController.dispose();
    });
  }

  void _openEditSubcategoryDialog(
    TranslationState langState,
    SubcategoryModel subcategory,
  ) {
    final nameEnController = TextEditingController(text: subcategory.nameEn);
    final nameArController = TextEditingController(text: subcategory.nameAr);
    CategoryModel? selectedCategory;
    XFile? selectedImage;
    Uint8List? selectedImageBytes;
    bool isActive = subcategory.isActive;
    bool isUploading = false;
    String imageUrl = subcategory.imageUrl;
    bool hasChanges = false;
    bool isSubmitting = false;

    // Load initial category
    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is CategoryLoaded) {
      try {
        selectedCategory = categoryState.categories.firstWhere(
          (c) => c.id == subcategory.parentId,
        );
      } catch (e) {
        if (subcategory.parentNameEn != null &&
            subcategory.parentNameEn!.isNotEmpty) {
          selectedCategory = CategoryModel(
            id: subcategory.parentId,
            nameEn: subcategory.parentNameEn!,
            nameAr: subcategory.parentNameAr ?? '',
            imageUrl: '',
            parentId: null,
            isActive: true,
            attributesSchema: const [],
            createdAt: null,
            updatedAt: null,
          );
        } else {
          selectedCategory = null;
        }
      }
    }

    void updateHasChanges() {
      final nameEn = nameEnController.text.trim();
      final nameAr = nameArController.text.trim();
      final changed =
          nameEn != subcategory.nameEn ||
          nameAr != subcategory.nameAr ||
          isActive != subcategory.isActive ||
          (selectedCategory != null &&
              selectedCategory!.id != subcategory.parentId) ||
          selectedImageBytes != null;
      hasChanges = changed;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocListener<SubcategoryBloc, SubcategoryState>(
              listener: (context, state) {
                if (!isSubmitting) return;

                if (state is SubcategoryLoaded) {
                  isSubmitting = false;
                  Navigator.pop(dialogContext);
                }

                if (state is SubcategoryError) {
                  isSubmitting = false;
                  isSubmittingSubcategory = false;
                  setDialogState(() {
                    isUploading = false;
                  });
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              child: BlocListener<S3UploadBloc, S3UploadState>(
                listener: (context, state) {
                  if (!isSubmitting) return;

                  if (state is S3UploadSuccess) {
                    imageUrl = state.result.url;
                    final model = SubcategoryModel(
                      id: subcategory.id,
                      nameEn: nameEnController.text.trim(),
                      nameAr: nameArController.text.trim(),
                      parentId: selectedCategory?.id ?? subcategory.parentId,
                      imageUrl: imageUrl,
                      isActive: isActive,
                      attributesSchema: subcategory.attributesSchema,
                    );
                    context.read<SubcategoryBloc>().add(
                      UpdateSubcategory(subcategory.id, model),
                    );
                  }

                  if (state is S3UploadFailure) {
                    isSubmitting = false;
                    isSubmittingSubcategory = false;
                    setDialogState(() {
                      isUploading = false;
                    });
                    ScaffoldMessenger.of(
                      dialogContext,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                child: AdminActionDialog(
                  title: _label(
                    langState,
                    "Update Sub Category",
                    "تحديث التصنيف الفرعي",
                  ),
                  submitText: _label(langState, "Update", "تحديث"),
                  submitEnabled: hasChanges && !isUploading,
                  submitLoading: isUploading,
                  submitColor: Colors.black,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (state is CategoryLoaded) {
                            final categories = List<CategoryModel>.from(
                              state.categories,
                            );
                            if (selectedCategory != null &&
                                !categories.any(
                                  (c) => c.id == selectedCategory!.id,
                                )) {
                              categories.add(selectedCategory!);
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE1E1E1),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<CategoryModel>(
                                  value: selectedCategory,
                                  isExpanded: true,
                                  hint: DynamicText(
                                    _label(langState, "Category", "التصنيف"),
                                    style: AppThemes.f14w400.copyWith(
                                      color: Color(0xFF99A1AF),
                                    ),
                                  ),
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: categories.map((category) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: DynamicText(
                                        langState.isRTL
                                            ? category.nameAr
                                            : category.nameEn,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      selectedCategory = value;
                                      updateHasChanges();
                                    });
                                  },
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomTextFormField(
                        controller: nameEnController,
                        onChanged: (_) => setDialogState(updateHasChanges),
                        labelText: _label(
                          langState,
                          "Category Name",
                          "الاسم بالإنجليزية",
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextFormField(
                        controller: nameArController,
                        onChanged: (_) => setDialogState(updateHasChanges),
                        labelText: _label(
                          langState,
                          "Name AR",
                          "الاسم بالعربية",
                        ),
                        suffixIcon: const Icon(Icons.translate),
                        onSuffixTap: () async {
                          final nameEn = nameEnController.text.trim();
                          if (nameEn.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _label(
                                    langState,
                                    "Please enter English name first",
                                    "يرجى إدخال الاسم بالإنجليزية أولاً",
                                  ),
                                ),
                              ),
                            );
                            return;
                          }
                          final translated = await TranslationService.translate(
                            nameEn,
                            'ar',
                          );
                          nameArController.text = translated;
                          setDialogState(updateHasChanges);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE1E1E1),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DynamicText(
                                selectedImage?.name ??
                                    (imageUrl.isNotEmpty
                                        ? _label(
                                            langState,
                                            "Image selected",
                                            "تم اختيار صورة",
                                          )
                                        : _label(
                                            langState,
                                            "No image selected",
                                            "لم يتم اختيار صورة",
                                          )),
                                style: AppThemes.f16w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: Icon(Icons.image),
                            onPressed: () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (file == null) return;
                              final bytes = await file.readAsBytes();
                              setDialogState(() {
                                selectedImage = file;
                                selectedImageBytes = bytes;
                                updateHasChanges();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DynamicText(
                        _label(langState, "Status", "الحالة"),
                        style: AppThemes.f14w400.copyWith(
                          color: Color(0xFF8A8A8A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE1E1E1)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<bool>(
                            value: isActive,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: [
                              DropdownMenuItem(
                                value: true,
                                child: DynamicText(
                                  _label(langState, "Active", "نشط"),
                                ),
                              ),
                              DropdownMenuItem(
                                value: false,
                                child: DynamicText(
                                  _label(langState, "Inactive", "غير نشط"),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  isActive = value;
                                  updateHasChanges();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      if (isUploading)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                  onSubmit: () async {
                    if (!hasChanges || isUploading) return;

                    final nameEn = nameEnController.text.trim();
                    final nameAr = nameArController.text.trim();
                    if (nameEn.isEmpty && nameAr.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            _label(
                              langState,
                              "Please enter a name",
                              "يرجى إدخال اسم",
                            ),
                          ),
                        ),
                      );
                      return;
                    }

                    isSubmitting = true;
                    isSubmittingSubcategory = true;
                    pendingActionMessage = _label(
                      langState,
                      "Sub Category updated successfully",
                      "تم تحديث التصنيف الفرعي بنجاح",
                    );

                    setDialogState(() {
                      isUploading = true;
                    });

                    if (selectedImageBytes != null) {
                      context.read<S3UploadBloc>().add(
                        UploadFile(
                          bytes: selectedImageBytes!,
                          filename: selectedImage!.name,
                          folder: "SubCategories",
                        ),
                      );
                    } else {
                      final model = SubcategoryModel(
                        id: subcategory.id,
                        nameEn: nameEn,
                        nameAr: nameAr,
                        parentId: selectedCategory?.id ?? subcategory.parentId,
                        imageUrl: imageUrl,
                        isActive: isActive,
                        attributesSchema: subcategory.attributesSchema,
                      );
                      context.read<SubcategoryBloc>().add(
                        UpdateSubcategory(subcategory.id, model),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      nameEnController.dispose();
      nameArController.dispose();
    });
  }

  void _navigateToAttributes(
    BuildContext context,
    SubcategoryModel subcategory,
    TranslationState langState,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttributeMobileView(subcategory: subcategory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, langState) {
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            // no op for now
          },
          child: BlocListener<SubcategoryBloc, SubcategoryState>(
            listener: (context, state) {
              if (!isSubmittingSubcategory) return;

              if (state is SubcategoryLoaded) {
                isSubmittingSubcategory = false;
                if (pendingActionMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(pendingActionMessage!)),
                  );
                  pendingActionMessage = null;
                }
              }

              if (state is SubcategoryError) {
                isSubmittingSubcategory = false;
                pendingActionMessage = null;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: Scaffold(
              backgroundColor: AppColors.scaffoldColor,
              body: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          DynamicText(
                            _label(
                              langState,
                              "Sub category",
                              "التصنيفات الفرعية",
                            ),
                            style: AppThemes.f20w600,
                          ),
                          const SizedBox(height: 8),
                          DynamicText(
                            _label(
                              langState,
                              "Manage sub categories for each category",
                              "إدارة التصنيفات الفرعية لكل تصنيف",
                            ),
                            style: AppThemes.f14w400,
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
                                          "Search Sub categories..",
                                          "ابحث عن التصنيفات الفرعية",
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
                                            "+ Sub category",
                                            "+ إضافة تصنيف فرعي",
                                          ),
                                          color: Colors.black,
                                          onPressed: () {
                                            _openAddSubcategoryDialog(
                                              langState,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth:
                                          MediaQuery.of(context).size.width -
                                          48,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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
                                              SizedBox(
                                                width: 60,
                                                child: DynamicText(
                                                  _label(
                                                    langState,
                                                    'Image',
                                                    'صورة',
                                                  ),
                                                  style: AppThemes.f14w600,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              SizedBox(
                                                width: 140,
                                                child: DynamicText(
                                                  _label(
                                                    langState,
                                                    'Name',
                                                    'الاسم',
                                                  ),
                                                  style: AppThemes.f14w600,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 140,
                                                child: DynamicText(
                                                  _label(
                                                    langState,
                                                    'Category',
                                                    'التصنيف',
                                                  ),
                                                  style: AppThemes.f14w600,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 90,
                                                child: Center(
                                                  child: DynamicText(
                                                    _label(
                                                      langState,
                                                      'Status',
                                                      'الحالة',
                                                    ),
                                                    style: AppThemes.f14w600,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 120,
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
                                        BlocBuilder<
                                          SubcategoryBloc,
                                          SubcategoryState
                                        >(
                                          builder: (context, state) {
                                            if (state is SubcategoryLoading) {
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                  24,
                                                ),
                                                child: Column(
                                                  children: List.generate(
                                                    6,
                                                    (index) => Padding(
                                                      padding: EdgeInsets.only(
                                                        bottom: index == 5
                                                            ? 0
                                                            : 20,
                                                      ),
                                                      child:
                                                          const _SubcategoryShimmerRowMobile(),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                            if (state is SubcategoryLoaded) {
                                              final query = searchController
                                                  .text
                                                  .trim()
                                                  .toLowerCase();
                                              final filteredSubcategories =
                                                  state.subcategories.where((
                                                    subcat,
                                                  ) {
                                                    if (query.isEmpty)
                                                      return true;
                                                    return subcat.nameEn
                                                            .toLowerCase()
                                                            .contains(query) ||
                                                        subcat.nameAr
                                                            .toLowerCase()
                                                            .contains(query);
                                                  }).toList();

                                              if (filteredSubcategories
                                                  .isEmpty) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                    20,
                                                  ),
                                                  child: DynamicText(
                                                    _label(
                                                      langState,
                                                      "No subcategories present",
                                                      "لا توجد تصنيفات فرعية",
                                                    ),
                                                  ),
                                                );
                                              }
                                              return Column(
                                                children: filteredSubcategories
                                                    .map((item) {
                                                      return _buildMobileSubcatRow(
                                                        item,
                                                        langState,
                                                        langState.isRTL,
                                                      );
                                                    })
                                                    .toList(),
                                              );
                                            }
                                            if (state is SubcategoryError) {
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                  20,
                                                ),
                                                child: Text(
                                                  state.message,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                        BlocBuilder<
                                          SubcategoryBloc,
                                          SubcategoryState
                                        >(
                                          builder: (context, state) {
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                        const SizedBox(height: 10),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileSubcatRow(
    SubcategoryModel item,
    TranslationState langState,
    bool isRTL,
  ) {
    // Determine category name
    final preferredParentName = isRTL ? item.parentNameAr : item.parentNameEn;
    final categoryState = context.read<CategoryBloc>().state;
    String categoryName =
        (preferredParentName != null && preferredParentName.trim().isNotEmpty)
        ? preferredParentName
        : item.parentId;
    if ((preferredParentName == null || preferredParentName.trim().isEmpty) &&
        categoryState is CategoryLoaded) {
      CategoryModel? match;
      for (final c in categoryState.categories) {
        if (c.id == item.parentId) {
          match = c;
          break;
        }
      }
      if (match != null) {
        categoryName = isRTL ? match.nameAr : match.nameEn;
      }
    }

    final resolvedUrl = item.imageUrl.trim();
    final hasImage = resolvedUrl.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEFEFEF))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFEFEFEF),
              child: ClipOval(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: hasImage
                      ? Image.network(
                          resolvedUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 18,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 18,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: DynamicText(
              isRTL ? item.nameAr : item.nameEn,
              style: AppThemes.f14w400,
            ),
          ),
          SizedBox(
            width: 140,
            child: DynamicText(categoryName, style: AppThemes.f14w400),
          ),
          SizedBox(
            width: 90,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: item.isActive
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DynamicText(
                  item.isActive
                      ? _label(langState, "Active", "نشط")
                      : _label(langState, "Inactive", "غير نشط"),
                  style: AppThemes.f12w500.copyWith(
                    color: item.isActive
                        ? const Color(0xFF166534)
                        : const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => _navigateToAttributes(context, item, langState),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.list_alt,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _openEditSubcategoryDialog(langState, item),
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
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _openDeleteSubcategoryDialog(langState, item),
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

class _SubcategoryShimmerRowMobile extends StatelessWidget {
  const _SubcategoryShimmerRowMobile();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: 0.85),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Row(
            children: [
              const SizedBox(
                width: 60,
                child: _ShimmerBoxMobile(width: 36, height: 36, radius: 18),
              ),
              const SizedBox(width: 8),
              const SizedBox(
                width: 140,
                child: _ShimmerBoxMobile(width: double.infinity, height: 20),
              ),
              const SizedBox(
                width: 140,
                child: _ShimmerBoxMobile(width: double.infinity, height: 20),
              ),
              const SizedBox(
                width: 90,
                child: Center(child: _ShimmerBoxMobile(width: 60, height: 20)),
              ),
              const SizedBox(
                width: 120,
                child: Center(child: _ShimmerBoxMobile(width: 80, height: 20)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBoxMobile extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBoxMobile({
    required this.width,
    required this.height,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
