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

    context.read<CategoryBloc>().add(LoadCategories());

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
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          final categories = state is CategoryLoaded
                              ? state.categories
                              : <CategoryModel>[];
                          return DropdownButtonFormField<CategoryModel>(
                            value: selectedCategory,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFEFEFEF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEFEFEF),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEFEFEF),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFEFEFEF),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 18,
                              ),
                            ),
                            hint: const DynamicText("Select category"),
                            items: categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.nameEn),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                            },
                          );
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
