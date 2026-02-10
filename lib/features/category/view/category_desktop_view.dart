import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_state.dart';
import 'dart:typed_data';

import 'package:_96sooq_admin/core/bloc/language/translation_service.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_bloc.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_event.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_state.dart';
import 'package:_96sooq_admin/features/auth/bloc/auth_bloc.dart';
import 'package:_96sooq_admin/features/auth/bloc/auth_state.dart';
import 'package:_96sooq_admin/features/category/bloc/category_bloc.dart';
import 'package:_96sooq_admin/features/category/bloc/category_event.dart';
import 'package:_96sooq_admin/features/category/bloc/category_state.dart';
import 'package:_96sooq_admin/features/category/model/category_model.dart';
import 'package:_96sooq_admin/features/category/widgets/add_category_popup.dart';
import 'package:_96sooq_admin/features/category/widgets/category_list_widget.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryDesktopView extends StatefulWidget {
  const CategoryDesktopView({super.key});

  @override
  State<CategoryDesktopView> createState() => _CategoryDesktopViewState();
}

class _CategoryDesktopViewState extends State<CategoryDesktopView> {
  final TextEditingController searchController = TextEditingController();
  bool isSubmittingCategory = false;
  String? pendingActionMessage;
  bool hasLoadedCategories = false;
  bool isCreatingCategory = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && !hasLoadedCategories) {
      hasLoadedCategories = true;
      context.read<CategoryBloc>().add(LoadCategories());
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _createCategory({
    required String nameEn,
    required String nameAr,
    required String imageUrl,
    required bool isActive,
  }) {
    context.read<CategoryBloc>().add(
          CreateCategory(
            CategoryModel(
              id: '',
              nameEn: nameEn,
              nameAr: nameAr,
              imageUrl: imageUrl,
              parentId: null,
              attributesSchema: const [],
              isActive: isActive,
          createdAt: null,
          updatedAt: null,
        ),
      ),
    );
  }

  void _updateCategory({
    required String id,
    required String nameEn,
    required String nameAr,
    required String imageUrl,
    required bool isActive,
  }) {
    context.read<CategoryBloc>().add(
          UpdateCategory(
            id,
            CategoryModel(
              id: id,
              nameEn: nameEn,
              nameAr: nameAr,
              imageUrl: imageUrl,
              parentId: null,
              attributesSchema: const [],
              isActive: isActive,
              createdAt: null,
              updatedAt: null,
            ),
          ),
        );
  }

  void _deleteCategory(String id) {
    context.read<CategoryBloc>().add(DeleteCategory(id));
  }

  String _label(TranslationState state, String en, String ar) {
    return state.isRTL ? ar : en;
  }

  void _openAddCategoryDialog(TranslationState langState) {
    final nameEnController = TextEditingController();
    final nameArController = TextEditingController();
    XFile? selectedImage;
    Uint8List? selectedImageBytes;
    bool isActive = true;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocListener<S3UploadBloc, S3UploadState>(
              listener: (context, state) {
                if (state is S3UploadSuccess) {
                  _createCategory(
                    nameEn: nameEnController.text.trim(),
                    nameAr: nameArController.text.trim(),
                    imageUrl: state.result.url,
                    isActive: isActive,
                  );
                  Navigator.pop(dialogContext);
                }

                if (state is S3UploadFailure) {
                  isSubmittingCategory = false;
                  setDialogState(() {
                    isUploading = false;
                  });
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              child: AdminActionDialog(
                title: _label(langState, "Add Category", "إضافة تصنيف"),
                submitText: _label(langState, "Create", "إنشاء"),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      controller: nameEnController,
                      labelText: _label(
                        langState,
                        "Name EN",
                        "الاسم بالإنجليزية",
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: nameArController,
                      labelText:
                          _label(langState, "Name AR", "الاسم بالعربية"),
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
                        CustomButton(
                          text: _label(
                            langState,
                            "Choose Image",
                            "اختر صورة",
                          ),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final file = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (file == null) {
                              return;
                            }

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
                    SwitchListTile(
                      value: isActive,
                      onChanged: (value) {
                        setDialogState(() {
                          isActive = value;
                        });
                      },
                      title: DynamicText(
                        _label(langState, "Active", "نشط"),
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

                  isSubmittingCategory = true;
                  pendingActionMessage = _label(
                    langState,
                    "Category created successfully",
                    "تم إنشاء التصنيف بنجاح",
                  );
                  setState(() {
                    isCreatingCategory = true;
                  });
                  setDialogState(() {
                    isUploading = true;
                  });

                  context.read<S3UploadBloc>().add(
                        UploadFile(
                          bytes: selectedImageBytes!,
                          filename: selectedImage!.name,
                          folder: "Categories",
                        ),
                      );
                },
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

  void _openEditCategoryDialog(
    TranslationState langState,
    CategoryModel category,
  ) {
    final nameEnController = TextEditingController(text: category.nameEn);
    final nameArController = TextEditingController(text: category.nameAr);
    XFile? selectedImage;
    Uint8List? selectedImageBytes;
    bool isActive = category.isActive;
    bool isUploading = false;
    String imageUrl = category.imageUrl;
    bool hasChanges = false;
    bool awaitingUpdatePop = false;

    void updateHasChanges() {
      final nameEn = nameEnController.text.trim();
      final nameAr = nameArController.text.trim();
      final changed = nameEn != category.nameEn ||
          nameAr != category.nameAr ||
          isActive != category.isActive ||
          selectedImageBytes != null;
      hasChanges = changed;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocListener<CategoryBloc, CategoryState>(
              listener: (context, state) {
                if (!awaitingUpdatePop) return;
                if (state is CategoryLoaded || state is CategoryError) {
                  awaitingUpdatePop = false;
                  Navigator.pop(dialogContext);
                }
              },
              child: BlocListener<S3UploadBloc, S3UploadState>(
                listener: (context, state) {
                  if (state is S3UploadSuccess) {
                    imageUrl = state.result.url;
                    awaitingUpdatePop = true;
                    _updateCategory(
                      id: category.id,
                      nameEn: nameEnController.text.trim(),
                      nameAr: nameArController.text.trim(),
                      imageUrl: imageUrl,
                      isActive: isActive,
                    );
                  }

                  if (state is S3UploadFailure) {
                    isSubmittingCategory = false;
                    setDialogState(() {
                      isUploading = false;
                    });
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                child: AdminActionDialog(
                title: _label(langState, "Update Category", "تحديث التصنيف"),
                submitText: _label(langState, "Update", "تحديث"),
                submitEnabled: hasChanges && !isUploading,
                submitLoading: isUploading,
                submitColor:
                    hasChanges ? AppColors.primaryColor : const Color(0xFFE5E7EB),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      controller: nameEnController,
                      onChanged: (_) {
                        setDialogState(updateHasChanges);
                      },
                      labelText: _label(
                        langState,
                        "Name EN",
                        "الاسم بالإنجليزية",
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: nameArController,
                      onChanged: (_) {
                        setDialogState(updateHasChanges);
                      },
                      labelText:
                          _label(langState, "Name AR", "الاسم بالعربية"),
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
                        CustomButton(
                          text: _label(
                            langState,
                            "Choose Image",
                            "اختر صورة",
                          ),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final file = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (file == null) {
                              return;
                            }

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
                    SwitchListTile(
                      value: isActive,
                      onChanged: (value) {
                        setDialogState(() {
                          isActive = value;
                          updateHasChanges();
                        });
                      },
                      title: DynamicText(
                        _label(langState, "Active", "نشط"),
                      ),
                    ),
                  ],
                ),
                onSubmit: () async {
                  final nameEn = nameEnController.text.trim();
                  final nameAr = nameArController.text.trim();
                  if (!hasChanges || isUploading) {
                    return;
                  }
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

                  pendingActionMessage = _label(
                    langState,
                    "Category updated successfully",
                    "تم تحديث التصنيف بنجاح",
                  );

                  if (selectedImageBytes == null) {
                    isSubmittingCategory = true;
                    setDialogState(() {
                      isUploading = true;
                    });
                    awaitingUpdatePop = true;
                    _updateCategory(
                      id: category.id,
                      nameEn: nameEnController.text.trim(),
                      nameAr: nameArController.text.trim(),
                      imageUrl: imageUrl,
                      isActive: isActive,
                    );
                    return;
                  }

                  isSubmittingCategory = true;
                  setDialogState(() {
                    isUploading = true;
                  });

                  context.read<S3UploadBloc>().add(
                        UploadFile(
                          bytes: selectedImageBytes!,
                          filename: selectedImage!.name,
                          folder: "Categories",
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

  void _openDeleteCategoryDialog(
    TranslationState langState,
    CategoryModel category,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AdminActionDialog(
          title: _label(langState, "Delete Category", "حذف التصنيف"),
          submitText: _label(langState, "Delete", "حذف"),
          child: DynamicText(
            _label(
              langState,
              "Are you sure you want to delete this category?",
              "هل أنت متأكد أنك تريد حذف هذا التصنيف؟",
            ),
            style: AppThemes.f18w400,
          ),
          onSubmit: () {
            isSubmittingCategory = true;
            pendingActionMessage = _label(
              langState,
              "Category deleted successfully",
              "تم حذف التصنيف بنجاح",
            );
            _deleteCategory(category.id);
            Navigator.pop(dialogContext);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationBloc, TranslationState>(
      builder: (context, langState) {
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState is Unauthenticated) {
              hasLoadedCategories = false;
            }
          },
          child: BlocListener<CategoryBloc, CategoryState>(
            listener: (context, state) {
              if (!isSubmittingCategory) return;

            if (state is CategoryLoaded) {
              isSubmittingCategory = false;
              if (isCreatingCategory) {
                setState(() {
                  isCreatingCategory = false;
                });
              }
              if (pendingActionMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(pendingActionMessage!)),
                );
                pendingActionMessage = null;
              }
              }

            if (state is CategoryError) {
              isSubmittingCategory = false;
              if (isCreatingCategory) {
                setState(() {
                  isCreatingCategory = false;
                });
              }
              pendingActionMessage = null;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            },
            child: Scaffold(
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
                        DynamicText(
                          _label(langState, "Category", "التصنيفات"),
                          style: AppThemes.f28w600,
                        ),
                        const SizedBox(height: 10),
                        DynamicText(
                          _label(
                            langState,
                            "Manage your marketplace categories",
                            "إدارة تصنيفات السوق",
                          ),
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
                                  horizontal: 55,
                                  vertical: 55,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment: .center,
                                    crossAxisAlignment: .center,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: CustomTextFormField(
                                          controller: searchController,
                                          labelText: _label(
                                            langState,
                                            "Search Categories",
                                            "ابحث في التصنيفات",
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.search,
                                            color: Color(0xFF99A1Af),
                                          ),
                                        ),
                                      ),
                                      Spacer(flex: 1),
                                      Expanded(
                                        flex: 1,
                                        child: CustomButton(
                                          text: _label(
                                            langState,
                                            "+ Category",
                                            "+ إضافة تصنيف",
                                          ),
                                          onPressed: () {
                                            _openAddCategoryDialog(langState);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFF9FAFB),
                                  border: Border.all(color: Color(0xFFE1E1E1)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 40),
                                      Expanded(
                                        flex: 1,
                                        child: DynamicText(
                                          _label(
                                            langState,
                                            'Image',
                                            'الصورة',
                                          ),
                                          style: AppThemes.f20w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 3,
                                        child: DynamicText(
                                          _label(
                                            langState,
                                            'Category Name',
                                            'اسم التصنيف',
                                          ),
                                          style: AppThemes.f20w500,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: DynamicText(
                                            _label(
                                              langState,
                                              'Status',
                                              'الحالة',
                                            ),
                                            style: AppThemes.f20w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: DynamicText(
                                            _label(
                                              langState,
                                              'Actions',
                                              'الإجراءات',
                                            ),
                                            style: AppThemes.f20w500,
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              BlocBuilder<CategoryBloc, CategoryState>(
                                builder: (context, state) {
                                  if (state is CategoryLoading) {
                                    return Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        children: List.generate(
                                          8,
                                          (index) => Padding(
                                            padding: EdgeInsets.only(
                                              bottom: index == 7 ? 0 : 20,
                                            ),
                                            child: const _CategoryShimmerRow(),
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  if (state is CategoryLoaded) {
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: state.categories.length +
                                          (isCreatingCategory ? 1 : 0),
                                      itemBuilder: (context, index) {
                                        if (isCreatingCategory && index == 0) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 18,
                                            ),
                                            child: _CategoryShimmerRow(),
                                          );
                                        }

                                        final itemIndex = isCreatingCategory
                                            ? index - 1
                                            : index;
                                        final category =
                                            state.categories[itemIndex];
                                        final isCategoryActive =
                                            category.isActive;
                                        final statusLabel = isCategoryActive
                                            ? _label(langState, "Active", "نشط")
                                            : _label(
                                                langState,
                                                "Inactive",
                                                "غير نشط",
                                              );

                                        final isArabic = langState.isRTL;
                                        final displayName = isArabic
                                            ? category.nameAr
                                            : category.nameEn;
                                        return CategoryListWidget(
                                          imageUrl: category.imageUrl,
                                          name: displayName,
                                          isActive: isCategoryActive,
                                          statusLabel: statusLabel,
                                          onEdit: () =>
                                              _openEditCategoryDialog(
                                            langState,
                                            category,
                                          ),
                                          onDelete:
                                              () => _openDeleteCategoryDialog(
                                            langState,
                                            category,
                                          ),
                                        );
                                      },
                                    );
                                  }

                                  if (state is CategoryError) {
                                    return Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: DynamicText(state.message),
                                    );
                                  }

                                  return const SizedBox();
                                },
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
}

class _CategoryShimmerRow extends StatelessWidget {
  const _CategoryShimmerRow();

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
              const SizedBox(width: 40),
              _ShimmerBox(width: 36, height: 36, radius: 18),
              const SizedBox(width: 12),
              const Expanded(
                flex: 3,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              const SizedBox(width: 40),
            ],
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
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
