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
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryMobileView extends StatefulWidget {
  const CategoryMobileView({super.key});

  @override
  State<CategoryMobileView> createState() => _CategoryMobileViewState();
}

class _CategoryMobileViewState extends State<CategoryMobileView> {
  final TextEditingController searchController = TextEditingController();
  bool isSubmittingCategory = false;
  String? pendingActionMessage;
  bool isCreatingCategory = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<CategoryBloc>().add(LoadCategories());
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
      context.read<CategoryBloc>().add(LoadMoreCategories());
    }
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
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              child: AdminActionDialog(
                title: _label(langState, "Add Category", "إضافة تصنيف"),
                submitText: _label(langState, "Add", "إضافة"),
                submitColor: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      labelText: _label(langState, "Name AR", "الاسم بالعربية"),
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
      final changed =
          nameEn != category.nameEn ||
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
                    ScaffoldMessenger.of(
                      dialogContext,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                child: AdminActionDialog(
                  title: _label(langState, "Update Category", "تحديث التصنيف"),
                  submitText: _label(langState, "Update", "تحديث"),
                  submitEnabled: hasChanges && !isUploading,
                  submitLoading: isUploading,
                  submitColor: Colors.black,
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
                          "Category Name",
                          "الاسم بالإنجليزية",
                        ),
                      ),
                      const SizedBox(height: 12),
                      CustomTextFormField(
                        controller: nameArController,
                        onChanged: (_) {
                          setDialogState(updateHasChanges);
                        },
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
            // no op for now
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
                            _label(langState, "Category", "التصنيفات"),
                            style: AppThemes.f20w600,
                          ),
                          const SizedBox(height: 8),
                          DynamicText(
                            _label(
                              langState,
                              "Manage your marketplace categories",
                              "إدارة تصنيفات السوق",
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
                                /// Top Bar Mobile Specific Layout
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
                                          "Search categories..",
                                          "ابحث في التصنيفات",
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
                                            "+ Category",
                                            "+ إضافة تصنيف",
                                          ),
                                          color: Colors.black,
                                          onPressed: () {
                                            _openAddCategoryDialog(langState);
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
                                          _label(
                                            langState,
                                            'Category Name',
                                            'اسم التصنيف',
                                          ),
                                          style: AppThemes.f14w600,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
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
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                BlocBuilder<CategoryBloc, CategoryState>(
                                  builder: (context, state) {
                                    if (state is CategoryLoading) {
                                      return Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          children: List.generate(
                                            6,
                                            (index) => Padding(
                                              padding: EdgeInsets.only(
                                                bottom: index == 5 ? 0 : 20,
                                              ),
                                              child:
                                                  const _CategoryShimmerRowMobile(),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    if (state is CategoryLoaded) {
                                      final query = searchController.text
                                          .trim()
                                          .toLowerCase();
                                      final filteredCategories = state
                                          .categories
                                          .where((cat) {
                                            if (query.isEmpty) return true;
                                            return cat.nameEn
                                                    .toLowerCase()
                                                    .contains(query) ||
                                                cat.nameAr
                                                    .toLowerCase()
                                                    .contains(query);
                                          })
                                          .toList();

                                      if (filteredCategories.isEmpty) {
                                        return Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: DynamicText(
                                            _label(
                                              langState,
                                              "No categories present",
                                              "لا توجد تصنيفات للبحث المحدد",
                                            ),
                                          ),
                                        );
                                      }
                                      return ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: filteredCategories.length,
                                        itemBuilder: (context, index) {
                                          final item =
                                              filteredCategories[index];
                                          return _buildMobileCategoryRow(
                                            item,
                                            langState,
                                            langState.isRTL,
                                          );
                                        },
                                      );
                                    }
                                    if (state is CategoryError) {
                                      return Padding(
                                        padding: const EdgeInsets.all(20),
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
                                BlocBuilder<CategoryBloc, CategoryState>(
                                  builder: (context, state) {
                                    if (state is CategoryLoaded &&
                                        state.hasMore &&
                                        searchController.text.trim().isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 30,
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileCategoryRow(
    CategoryModel item,
    TranslationState langState,
    bool isRTL,
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
              isRTL ? item.nameAr : item.nameEn,
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
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => _openEditCategoryDialog(langState, item),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _openDeleteCategoryDialog(langState, item),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
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

class _CategoryShimmerRowMobile extends StatelessWidget {
  const _CategoryShimmerRowMobile();

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
              const Expanded(
                flex: 2,
                child: _ShimmerBoxMobile(width: double.infinity, height: 20),
              ),
              const SizedBox(width: 8),
              const Expanded(
                flex: 1,
                child: _ShimmerBoxMobile(width: double.infinity, height: 20),
              ),
              const SizedBox(width: 8),
              const Expanded(
                flex: 1,
                child: _ShimmerBoxMobile(width: double.infinity, height: 20),
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

  const _ShimmerBoxMobile({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
