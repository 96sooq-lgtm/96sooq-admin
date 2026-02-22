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
  final ScrollController _scrollController = ScrollController();
  static const double _categoryPickerHeight = 360;
  static const double _categoryLoadMoreThreshold = 120;

  void _ensureCategoriesLoaded() {
    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is! CategoryLoaded && categoryState is! CategoryLoading) {
      context.read<CategoryBloc>().add(LoadCategories());
    }
  }

  void _autoLoadMoreCategories() {
    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is CategoryLoaded &&
        categoryState.hasMore &&
        !categoryState.isLoadingMore) {
      context.read<CategoryBloc>().add(LoadMoreCategories());
    }
  }

  Future<CategoryModel?> _openCategoryPicker({
    required CategoryModel? selectedCategory,
  }) async {
    _ensureCategoriesLoaded();
    return showDialog<CategoryModel>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.whiteTextColor,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: SizedBox(
            width: 460,
            height: _categoryPickerHeight,
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
                  child: BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is CategoryError) {
                        return Center(
                          child: TextButton(
                            onPressed: () => context.read<CategoryBloc>().add(
                              LoadCategories(),
                            ),
                            child: const Text("Retry loading categories"),
                          ),
                        );
                      }
                      final loadedState = state is CategoryLoaded
                          ? state
                          : null;
                      final categories = List<CategoryModel>.from(
                        loadedState?.categories ?? const <CategoryModel>[],
                      );
                      if (selectedCategory != null &&
                          !categories.any((c) => c.id == selectedCategory.id)) {
                        categories.insert(0, selectedCategory);
                      }

                      final itemCount =
                          categories.length +
                          (loadedState?.isLoadingMore == true ? 1 : 0);
                      return NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent -
                                  _categoryLoadMoreThreshold) {
                            _autoLoadMoreCategories();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            if (loadedState?.isLoadingMore == true &&
                                index == categories.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final category = categories[index];
                            final isSelected =
                                selectedCategory?.id == category.id;
                            return ListTile(
                              dense: true,
                              title: Text(category.nameEn),
                              trailing: isSelected
                                  ? const Icon(Icons.check, size: 18)
                                  : null,
                              onTap: () =>
                                  Navigator.pop(dialogContext, category),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryPickerTrigger({
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

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<SubcategoryBloc>().add(LoadSubcategories());
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
      context.read<SubcategoryBloc>().add(LoadMoreSubcategories());
    }
  }

  void _openAddSubcategoryDialog() {
    _ensureCategoriesLoaded();
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
                          if (!dialogContext.mounted) return;
                          nameArController.text = translated;
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryPickerTrigger(
                        selectedCategory: selectedCategory,
                        onTap: () async {
                          final picked = await _openCategoryPicker(
                            selectedCategory: selectedCategory,
                          );
                          if (picked == null) return;
                          setDialogState(() {
                            selectedCategory = picked;
                          });
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
    _ensureCategoriesLoaded();
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

    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is CategoryLoaded) {
      try {
        selectedCategory = categoryState.categories.firstWhere(
          (c) => c.id == subcategory.parentId,
        );
      } catch (_) {
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
        }
      }
    }

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
                      _buildCategoryPickerTrigger(
                        selectedCategory: selectedCategory,
                        onTap: () async {
                          final picked = await _openCategoryPicker(
                            selectedCategory: selectedCategory,
                          );
                          if (picked == null) return;
                          setDialogState(() {
                            selectedCategory = picked;
                          });
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
        controller: _scrollController,
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
                              return Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                                              preferredParentName
                                                  .trim()
                                                  .isNotEmpty)
                                          ? preferredParentName
                                          : item.parentId;
                                      if ((preferredParentName == null ||
                                              preferredParentName
                                                  .trim()
                                                  .isEmpty) &&
                                          categoryState is CategoryLoaded) {
                                        CategoryModel? match;
                                        for (final c
                                            in categoryState.categories) {
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
                                            _openDeleteSubcategoryDialog(
                                              item.id,
                                            ),
                                        onTap: () {
                                          final subBloc = context
                                              .read<SubcategoryBloc>();
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  BlocProvider.value(
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
                                  ),
                                  if (state.isLoadingMore)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      child: CircularProgressIndicator(),
                                    ),
                                ],
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
