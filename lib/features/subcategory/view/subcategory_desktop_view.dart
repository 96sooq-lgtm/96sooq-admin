import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'dart:typed_data';
import 'package:_96sooq_admin/core/bloc/language/translation_service.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/category/bloc/category_bloc.dart';
import 'package:_96sooq_admin/features/category/bloc/category_event.dart';
import 'package:_96sooq_admin/features/category/bloc/category_state.dart';
import 'package:_96sooq_admin/features/category/model/category_model.dart';
import 'package:_96sooq_admin/features/subcategory/widgets/subcategory_list_widget.dart';
import 'package:_96sooq_admin/features/subcategory/view/attribute/attribute_view.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_bloc.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_event.dart';
import 'package:_96sooq_admin/features/subcategory/bloc/subcategory_state.dart';
import 'package:_96sooq_admin/features/subcategory/model/subcategory_model.dart';
import 'package:_96sooq_admin/features/category/widgets/add_category_popup.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_bloc.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_event.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_state.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubcategoryDesktopView extends StatefulWidget {
  const SubcategoryDesktopView({super.key});

  @override
  State<SubcategoryDesktopView> createState() => _SubcategoryDesktopViewState();
}

class _SubcategoryDesktopViewState extends State<SubcategoryDesktopView> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<SubcategoryBloc>().add(LoadSubcategories());
  }

  void _openAddSubcategoryDialog() {
    final nameEnController = TextEditingController();
    final nameArController = TextEditingController();
    CategoryModel? selectedCategory;
    XFile? selectedImage;
    Uint8List? selectedImageBytes;
    bool isActive = true;
    bool isUploading = false;
    bool isSubmitting = false;
    bool disposed = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocListener<S3UploadBloc, S3UploadState>(
              listener: (context, state) {
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
                  setDialogState(() {
                    isSubmitting = true;
                  });
                }
                if (state is S3UploadFailure) {
                  setDialogState(() {
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
                  title: "Add Sub Category",
                  submitText: "Create",
                  submitLoading: isSubmitting || isUploading,
                  submitEnabled: !(isSubmitting || isUploading),
                  submitColor: AppColors.primaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextFormField(
                        controller: nameEnController,
                        labelText: "Name EN",
                      ),
                      const SizedBox(height: 12),
                      CustomTextFormField(
                        controller: nameArController,
                        labelText: "Name AR",
                        suffixIcon: const Icon(Icons.translate),
                        onSuffixTap: () async {
                          final nameEn = nameEnController.text.trim();
                          if (nameEn.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter English name first",
                                ),
                              ),
                            );
                            return;
                          }
                          final translated = await TranslationService.translate(
                            nameEn,
                            'ar',
                          );
                          if (disposed) return;
                          nameArController.text = translated;
                        },
                      ),
                      const SizedBox(height: 12),
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
                              setDialogState(() {
                                selectedCategory = value;
                              });
                            },
                          );
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
                        title: DynamicText("Active"),
                      ),
                    ],
                  ),
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
                    if (selectedImageBytes == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text("Please choose an image")),
                      );
                      return;
                    }
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

  void _openEditSubcategoryDialog(SubcategoryModel subcategory) {
    final nameEnController = TextEditingController(text: subcategory.nameEn);
    final nameArController = TextEditingController(text: subcategory.nameAr);
    CategoryModel? selectedCategory;
    XFile? selectedImage;
    Uint8List? selectedImageBytes;
    bool isActive = subcategory.isActive;
    bool isUploading = false;
    bool isSubmitting = false;
    String imageUrl = subcategory.imageUrl;
    bool disposed = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocListener<S3UploadBloc, S3UploadState>(
              listener: (context, state) {
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
                  setDialogState(() {
                    isSubmitting = true;
                  });
                }
                if (state is S3UploadFailure) {
                  setDialogState(() {
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
                    disposed = true;
                    Navigator.pop(dialogContext);
                  }
                },
                child: AdminActionDialog(
                  title: "Update Sub Category",
                  submitText: "Update",
                  submitLoading: isSubmitting || isUploading,
                  submitEnabled: !(isSubmitting || isUploading),
                  submitColor: AppColors.primaryColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextFormField(
                        controller: nameEnController,
                        labelText: "Name EN",
                      ),
                      const SizedBox(height: 12),
                      CustomTextFormField(
                        controller: nameArController,
                        labelText: "Name AR",
                        suffixIcon: const Icon(Icons.translate),
                        onSuffixTap: () async {
                          final nameEn = nameEnController.text.trim();
                          if (nameEn.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter English name first",
                                ),
                              ),
                            );
                            return;
                          }
                          final translated = await TranslationService.translate(
                            nameEn,
                            'ar',
                          );
                          if (disposed) return;
                          nameArController.text = translated;
                        },
                      ),
                      const SizedBox(height: 12),
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          final categories = List<CategoryModel>.from(
                            state is CategoryLoaded ? state.categories : [],
                          );
                          if (selectedCategory == null) {
                            for (final c in categories) {
                              if (c.id == subcategory.parentId) {
                                selectedCategory = c;
                                break;
                              }
                            }
                            // Fallback to the API's parent names if the full list doesn't have it yet
                            if (selectedCategory == null &&
                                subcategory.parentNameEn != null &&
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
                            }
                          }
                          if (selectedCategory != null &&
                              !categories.any(
                                (c) => c.id == selectedCategory!.id,
                              )) {
                            categories.add(selectedCategory!);
                          }
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
                              setDialogState(() {
                                selectedCategory = value;
                              });
                            },
                          );
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
                                        ? "Image selected"
                                        : "No image selected"),
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
                        title: DynamicText("Active"),
                      ),
                    ],
                  ),
                  onSubmit: () {
                    if (nameEnController.text.trim().isEmpty &&
                        nameArController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text("Please enter a name")),
                      );
                      return;
                    }
                    setDialogState(() {
                      isUploading = selectedImageBytes != null;
                      isSubmitting = true;
                    });
                    if (selectedImageBytes != null) {
                      context.read<S3UploadBloc>().add(
                        UploadFile(
                          bytes: selectedImageBytes!,
                          filename: selectedImage!.name,
                          folder: "Categories",
                        ),
                      );
                      return;
                    }
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
                  },
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      disposed = true;
      nameEnController.dispose();
      nameArController.dispose();
    });
  }

  void _openDeleteSubcategoryDialog(String id) {
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
                }
              },
              child: AdminActionDialog(
                title: "Delete Sub Category",
                submitText: "Delete",
                submitLoading: isDeleting,
                submitEnabled: !isDeleting,
                submitColor: Colors.black,
                child: DynamicText(
                  "Are you sure you want to delete this sub category?",
                  style: AppThemes.f18w400,
                ),
                onSubmit: () {
                  setDialogState(() {
                    isDeleting = true;
                  });
                  context.read<SubcategoryBloc>().add(DeleteSubcategory(id));
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
                  DynamicText("Sub Category", style: AppThemes.f28w600),
                  const SizedBox(height: 10),
                  DynamicText(
                    "Manage sub categories for each category",
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
                                    onChanged: (_) {
                                      setState(() {});
                                    },
                                    labelText: "Search Sub Categories",
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
                                    text: "+ Sub Category",
                                    onPressed: _openAddSubcategoryDialog,
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              children: const [
                                SizedBox(width: 40),
                                Expanded(
                                  flex: 1,
                                  child: DynamicText(
                                    'Image',
                                    style: AppThemes.f20w500,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: DynamicText(
                                    'Name',
                                    style: AppThemes.f20w500,
                                  ),
                                ),
                                SizedBox(width: 40),
                                Expanded(
                                  flex: 2,
                                  child: DynamicText(
                                    'Category',
                                    style: AppThemes.f20w500,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: DynamicText(
                                      'Status',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: DynamicText(
                                      'Actions',
                                      style: AppThemes.f20w500,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        BlocBuilder<SubcategoryBloc, SubcategoryState>(
                          builder: (context, state) {
                            if (state is SubcategoryLoading) {
                              return Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: List.generate(
                                    8,
                                    (index) => Padding(
                                      padding: EdgeInsets.only(
                                        bottom: index == 7 ? 0 : 20,
                                      ),
                                      child: const _SubcategoryShimmerRow(),
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (state is SubcategoryLoaded) {
                              final query = searchController.text
                                  .trim()
                                  .toLowerCase();
                              final filteredSubcategories = state.subcategories
                                  .where((sub) {
                                    if (query.isEmpty) return true;
                                    return sub.nameEn.toLowerCase().contains(
                                          query,
                                        ) ||
                                        sub.nameAr.toLowerCase().contains(
                                          query,
                                        );
                                  })
                                  .toList();

                              if (filteredSubcategories.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: DynamicText(
                                    "No subcategories present",
                                  ),
                                );
                              }
                              final isArabic = context
                                  .watch<TranslationBloc>()
                                  .state
                                  .isRTL;
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: filteredSubcategories.length,
                                itemBuilder: (context, index) {
                                  final item = filteredSubcategories[index];
                                  final preferredParentName = isArabic
                                      ? item.parentNameAr
                                      : item.parentNameEn;
                                  final categoryState = context
                                      .read<CategoryBloc>()
                                      .state;
                                  String categoryName =
                                      (preferredParentName != null &&
                                          preferredParentName.trim().isNotEmpty)
                                      ? preferredParentName
                                      : item.parentId;
                                  if ((preferredParentName == null ||
                                          preferredParentName.trim().isEmpty) &&
                                      categoryState is CategoryLoaded) {
                                    CategoryModel? match;
                                    for (final c in categoryState.categories) {
                                      if (c.id == item.parentId) {
                                        match = c;
                                        break;
                                      }
                                    }
                                    if (match != null) {
                                      categoryName = isArabic
                                          ? match.nameAr
                                          : match.nameEn;
                                    }
                                  }
                                  return SubcategoryListWidget(
                                    imageUrl: item.imageUrl,
                                    subCategoryName: isArabic
                                        ? item.nameAr
                                        : item.nameEn,
                                    categoryName: categoryName,
                                    status: item.isActive
                                        ? "Active"
                                        : "Inactive",
                                    onEdit: () =>
                                        _openEditSubcategoryDialog(item),
                                    onDelete: () =>
                                        _openDeleteSubcategoryDialog(item.id),
                                    onTap: () {
                                      final subBloc = context
                                          .read<SubcategoryBloc>();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider.value(
                                            value: subBloc,
                                            child: AttributeView(
                                              subcategory: item,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }
                            if (state is SubcategoryError) {
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
    );
  }
}

class _SubcategoryShimmerRow extends StatelessWidget {
  const _SubcategoryShimmerRow();

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
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: const _ShimmerBox(width: 50, height: 50, radius: 12),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              const SizedBox(width: 40),
              const Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              const Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _ShimmerBox(width: double.infinity, height: 18),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _ShimmerBox(width: double.infinity, height: 18),
                ),
              ),
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
