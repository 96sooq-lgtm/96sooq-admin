import 'dart:typed_data';

import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_bloc.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_event.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_state.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/category/bloc/category_bloc.dart';
import 'package:_96sooq_admin/features/category/bloc/category_event.dart';
import 'package:_96sooq_admin/features/category/bloc/category_state.dart';
import 'package:_96sooq_admin/features/category/model/category_model.dart';
import 'package:_96sooq_admin/features/category/widgets/add_category_popup.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_bloc.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_event.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_state.dart';
import 'package:_96sooq_admin/features/subcategory/model/subcategory_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

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
            DynamicText(
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
  static const double _categoryPickerDesktopHeight = 360;
  static const double _categoryPickerMobileHeightFactor = 0.72;
  static const double _categoryLoadMoreThreshold = 120;

  static void _ensureCategoriesLoaded(BuildContext context) {
    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is! CategoryLoaded && categoryState is! CategoryLoading) {
      context.read<CategoryBloc>().add(LoadCategories());
    }
  }

  static void _autoLoadMoreCategories(BuildContext context) {
    final state = context.read<CategoryBloc>().state;
    if (state is CategoryLoaded && state.hasMore && !state.isLoadingMore) {
      context.read<CategoryBloc>().add(LoadMoreCategories());
    }
  }

  static Widget _buildCategoryPickerTrigger({
    required CategoryModel? selectedCategory,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEFEFEF)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedCategory?.nameEn ?? "Select category",
                style: AppThemes.f14w400.copyWith(
                  color: selectedCategory == null
                      ? const Color(0xFF7A7A7A)
                      : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  static Widget _buildCategoryPickerList({
    required BuildContext context,
    required BuildContext sheetContext,
    required CategoryModel? selectedCategory,
    required ScrollController scrollController,
  }) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CategoryError) {
          return Center(
            child: TextButton(
              onPressed: () =>
                  context.read<CategoryBloc>().add(LoadCategories()),
              child: const Text("Retry loading categories"),
            ),
          );
        }

        final loadedState = state is CategoryLoaded ? state : null;
        final categories = List<CategoryModel>.from(
          loadedState?.categories ?? const <CategoryModel>[],
        );
        if (selectedCategory != null &&
            !categories.any((c) => c.id == selectedCategory.id)) {
          categories.insert(0, selectedCategory);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!scrollController.hasClients || loadedState == null) return;
          final position = scrollController.position;
          final isNearBottom =
              position.maxScrollExtent <= 0 ||
              position.pixels >=
                  position.maxScrollExtent - _categoryLoadMoreThreshold;
          if (isNearBottom &&
              loadedState.hasMore &&
              !loadedState.isLoadingMore) {
            _autoLoadMoreCategories(context);
          }
        });

        final itemCount =
            categories.length + (loadedState?.isLoadingMore == true ? 1 : 0);
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent -
                    _categoryLoadMoreThreshold) {
              _autoLoadMoreCategories(context);
            }
            return false;
          },
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (loadedState?.isLoadingMore == true &&
                  index == categories.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final category = categories[index];
              final isSelected = selectedCategory?.id == category.id;
              return ListTile(
                dense: true,
                title: Text(category.nameEn),
                trailing: isSelected ? const Icon(Icons.check, size: 18) : null,
                onTap: () => Navigator.pop(sheetContext, category),
              );
            },
          ),
        );
      },
    );
  }

  static Future<CategoryModel?> _openDashboardCategoryPicker(
    BuildContext context, {
    required CategoryModel? selectedCategory,
  }) async {
    _ensureCategoriesLoaded(context);
    final scrollController = ScrollController();
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    try {
      if (isDesktop) {
        return await showDialog<CategoryModel>(
          context: context,
          builder: (dialogContext) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: SizedBox(
                width: 460,
                height: _categoryPickerDesktopHeight,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Select category",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: _buildCategoryPickerList(
                        context: context,
                        sheetContext: dialogContext,
                        selectedCategory: selectedCategory,
                        scrollController: scrollController,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }

      return await showModalBottomSheet<CategoryModel>(
        backgroundColor: AppColors.whiteTextColor,
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) {
          return SizedBox(
            height:
                MediaQuery.of(sheetContext).size.height *
                _categoryPickerMobileHeightFactor,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Select category",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _buildCategoryPickerList(
                    context: context,
                    sheetContext: sheetContext,
                    selectedCategory: selectedCategory,
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } finally {
      scrollController.dispose();
    }
  }

  static void showAddCategoryDialog(BuildContext context) {
    final nameEnController = TextEditingController();
    final nameArController = TextEditingController();
    XFile? selectedImage;
    Uint8List? selectedImageBytes;
    bool isActive = true;
    bool isUploading = false;
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BlocListener<S3UploadBloc, S3UploadState>(
              listener: (context, state) {
                if (state is S3UploadSuccess) {
                  context.read<CategoryBloc>().add(
                    CreateCategory(
                      CategoryModel(
                        id: '',
                        nameEn: nameEnController.text.trim(),
                        nameAr: nameArController.text.trim(),
                        imageUrl: state.result.url,
                        parentId: null,
                        attributesSchema: const [],
                        isActive: isActive,
                        createdAt: null,
                        updatedAt: null,
                      ),
                    ),
                  );
                  setState(() {
                    isSubmitting = true;
                    isUploading = false;
                  });
                }
                if (state is S3UploadFailure) {
                  setState(() {
                    isUploading = false;
                    isSubmitting = false;
                  });
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              child: BlocListener<CategoryBloc, CategoryState>(
                listener: (context, state) {
                  if (!isSubmitting) return;
                  if (state is CategoryLoaded || state is CategoryError) {
                    Navigator.pop(dialogContext);
                  }
                },
                child: AdminActionDialog(
                  title: 'Add Category',
                  submitText: 'Create',
                  submitLoading: isSubmitting || isUploading,
                  submitEnabled: !(isSubmitting || isUploading),
                  submitColor: AppColors.primaryColor,
                  onSubmit: () {
                    if (nameEnController.text.trim().isEmpty &&
                        nameArController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Please enter a name')),
                      );
                      return;
                    }
                    if (selectedImageBytes == null || selectedImage == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Please choose an image')),
                      );
                      return;
                    }
                    setState(() {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DynamicText(
                        'Category Name English',
                        style: AppThemes.f20w400,
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Name EN",
                        controller: nameEnController,
                      ),
                      const SizedBox(height: 8),
                      DynamicText(
                        'Category Name Arabic',
                        style: AppThemes.f20w400,
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Name AR",
                        controller: nameArController,
                      ),
                      const SizedBox(height: 8),
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
                                selectedImage?.name ?? "No image selected",
                                style: AppThemes.f16w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.image_outlined),
                            onPressed: () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (file == null) return;
                              final bytes = await file.readAsBytes();
                              setState(() {
                                selectedImage = file;
                                selectedImageBytes = bytes;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        value: isActive,
                        onChanged: (value) {
                          setState(() => isActive = value);
                        },
                        title: const DynamicText('Active'),
                      ),
                    ],
                  ),
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

  static void showAddSubCategoryDialog(BuildContext context) {
    final nameEnController = TextEditingController();
    final nameArController = TextEditingController();
    CategoryModel? selectedCategory;
    XFile? selectedImage;
    Uint8List? selectedImageBytes;
    bool isActive = true;
    bool isUploading = false;
    bool isSubmitting = false;
    _ensureCategoriesLoaded(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BlocListener<S3UploadBloc, S3UploadState>(
              listener: (context, state) {
                if (state is S3UploadSuccess) {
                  context.read<SubcategoryBloc>().add(
                    CreateSubcategory(
                      SubcategoryModel(
                        id: '',
                        nameEn: nameEnController.text.trim(),
                        nameAr: nameArController.text.trim(),
                        parentId: selectedCategory?.id ?? '',
                        imageUrl: state.result.url,
                        isActive: isActive,
                        attributesSchema: null,
                      ),
                    ),
                  );
                  setState(() {
                    isSubmitting = true;
                    isUploading = false;
                  });
                }
                if (state is S3UploadFailure) {
                  setState(() {
                    isUploading = false;
                    isSubmitting = false;
                  });
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              child: BlocListener<SubcategoryBloc, SubcategoryState>(
                listener: (context, state) {
                  if (!isSubmitting) return;
                  if (state is SubcategorySuccess ||
                      state is SubcategoryError) {
                    Navigator.pop(dialogContext);
                  }
                },
                child: AdminActionDialog(
                  title: 'Add Sub Category',
                  submitText: "Create",
                  submitLoading: isSubmitting || isUploading,
                  submitEnabled: !(isSubmitting || isUploading),
                  submitColor: AppColors.primaryColor,
                  onSubmit: () {
                    if (nameEnController.text.trim().isEmpty &&
                        nameArController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text("Please enter a name")),
                      );
                      return;
                    }
                    if (selectedCategory == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a category"),
                        ),
                      );
                      return;
                    }
                    if (selectedImageBytes == null || selectedImage == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text("Please choose an image")),
                      );
                      return;
                    }
                    setState(() {
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DynamicText(
                        'Sub Category Name EN',
                        style: AppThemes.f20w400,
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Name EN",
                        controller: nameEnController,
                      ),
                      const SizedBox(height: 8),
                      DynamicText(
                        'Sub Category Name AR',
                        style: AppThemes.f20w400,
                      ),
                      const SizedBox(height: 8),
                      CustomTextFormField(
                        labelText: "Name AR",
                        controller: nameArController,
                      ),
                      const SizedBox(height: 8),
                      _buildCategoryPickerTrigger(
                        selectedCategory: selectedCategory,
                        onTap: () async {
                          final picked = await _openDashboardCategoryPicker(
                            context,
                            selectedCategory: selectedCategory,
                          );
                          if (picked == null) return;
                          setState(() {
                            selectedCategory = picked;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
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
                                selectedImage?.name ?? "No image selected",
                                style: AppThemes.f16w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.image_outlined),
                            onPressed: () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (file == null) return;
                              final bytes = await file.readAsBytes();
                              setState(() {
                                selectedImage = file;
                                selectedImageBytes = bytes;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        value: isActive,
                        onChanged: (value) {
                          setState(() => isActive = value);
                        },
                        title: const DynamicText('Active'),
                      ),
                    ],
                  ),
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
}
