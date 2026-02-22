import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_bloc.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_event.dart';
import 'package:_96sooq_admin/core/bloc/s3_upload/s3_upload_state.dart';
import 'package:_96sooq_admin/features/ad_bannner/bloc/ad_banner_bloc.dart';
import 'package:_96sooq_admin/features/ad_bannner/bloc/ad_banner_event.dart';
import 'package:_96sooq_admin/features/ad_bannner/bloc/ad_banner_state.dart';
import 'package:_96sooq_admin/features/ad_bannner/model/ad_banner_model.dart';
import 'package:_96sooq_admin/features/ad_bannner/widgets/ad_banner_listing_widget.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/category/widgets/add_category_popup.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class AdBannerViewDesktop extends StatefulWidget {
  const AdBannerViewDesktop({super.key});

  @override
  State<AdBannerViewDesktop> createState() => _AdBannerViewDesktopState();
}

class _AdBannerViewDesktopState extends State<AdBannerViewDesktop> {
  bool _hasLoaded = false;
  String? _pendingMutationAction;
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    if (!_hasLoaded) {
      _hasLoaded = true;
      context.read<AdBannerBloc>().add(LoadBanners());
    }
  }

  void _showMutationSuccessMessage(String action) {
    String message;
    switch (action) {
      case 'update':
        message = 'Banner updated successfully';
        break;
      case 'delete':
        message = 'Banner deleted successfully';
        break;
      default:
        message = 'Banner created successfully';
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showBannerPreviewDialog(String imageUrlsCsv) {
    if (imageUrlsCsv.trim().isEmpty) return;

    final urls = imageUrlsCsv
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (urls.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return OfferCarouselDialog(urls: urls);
      },
    );
  }

  Future<void> _openBannerLink(String rawLink) async {
    final trimmed = rawLink.trim();
    if (trimmed.isEmpty) return;
    final normalized =
        trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.tryParse(normalized);
    if (uri == null) return;
    final didLaunch = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!didLaunch && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open link')));
    }
  }

  void _openBannerDialog({AdBannerModel? existing}) {
    final isEditMode = existing != null;
    final bannerNameController = TextEditingController(
      text: existing?.name ?? '',
    );
    final bannerUrlController = TextEditingController(
      text: existing?.linkUrl ?? '',
    );
    final durationController = TextEditingController(
      text: existing == null ? '' : existing.durationDays.toString(),
    );
    final descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );

    XFile? selectedImage;
    Uint8List? selectedImageBytes;
    String currentImageUrl = existing?.imageUrl ?? '';
    bool isUploading = false;
    bool isSaving = false;
    bool isSubmittingFlow = false;

    void submitWithImageUrl(
      String imageUrl,
      void Function(void Function()) setDialogState,
    ) {
      final duration = int.tryParse(durationController.text.trim());
      if (duration == null || duration <= 0) {
        isSubmittingFlow = false;
        setDialogState(() {
          isUploading = false;
          isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Duration must be a positive number')),
        );
        return;
      }

      final model = AdBannerModel(
        id: existing?.id ?? '',
        name: bannerNameController.text.trim(),
        type: 'carousel',
        durationDays: duration,
        imageUrl: imageUrl,
        linkUrl: bannerUrlController.text.trim(),
        description: descriptionController.text.trim(),
        createdAt: existing?.createdAt,
        updatedAt: existing?.updatedAt,
      );

      setDialogState(() {
        isUploading = false;
        isSaving = true;
      });

      _pendingMutationAction = isEditMode ? 'update' : 'create';
      if (isEditMode) {
        context.read<AdBannerBloc>().add(
          UpdateBanner(id: existing.id, banner: model),
        );
      } else {
        context.read<AdBannerBloc>().add(CreateBanner(model));
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocListener<S3UploadBloc, S3UploadState>(
              listener: (context, state) {
                if (!isSubmittingFlow || !isUploading) return;

                if (state is S3UploadFailure) {
                  isSubmittingFlow = false;
                  setDialogState(() {
                    isUploading = false;
                    isSaving = false;
                  });
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }

                if (state is S3UploadSuccess) {
                  currentImageUrl = state.result.url;
                  submitWithImageUrl(currentImageUrl, setDialogState);
                }
              },
              child: BlocListener<AdBannerBloc, AdBannerState>(
                listener: (context, state) {
                  if (!isSubmittingFlow) return;

                  if (state is AdBannerError) {
                    isSubmittingFlow = false;
                    setDialogState(() {
                      isUploading = false;
                      isSaving = false;
                    });
                  }

                  if (state is AdBannerLoaded) {
                    isSubmittingFlow = false;
                    Navigator.pop(dialogContext);
                  }
                },
                child: AdminActionDialog(
                  title: isEditMode ? 'Edit Banner' : 'Add Banner',
                  submitText: isEditMode ? 'Update' : 'Create',
                  submitColor: AppColors.primaryColor,
                  submitLoading: isUploading || isSaving,
                  submitEnabled: !(isUploading || isSaving),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(dialogContext).size.height * 0.7,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DynamicText('Banner image', style: AppThemes.f16w500),
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
                                    selectedImage?.name ??
                                        (currentImageUrl.isNotEmpty
                                            ? 'Current image selected'
                                            : 'No image selected'),
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
                          DynamicText('Banner name', style: AppThemes.f16w500),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: bannerNameController,
                            labelText: 'Banner name',
                          ),
                          const SizedBox(height: 12),
                          DynamicText('Banner URL', style: AppThemes.f16w500),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: bannerUrlController,
                            labelText: 'Banner URL',
                          ),
                          const SizedBox(height: 12),
                          DynamicText(
                            'Duration in days',
                            style: AppThemes.f16w500,
                          ),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: durationController,
                            labelText: 'Duration in days',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 12),
                          DynamicText('Description', style: AppThemes.f16w500),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: descriptionController,
                            labelText: 'Description',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  onSubmit: () {
                    final duration = int.tryParse(
                      durationController.text.trim(),
                    );
                    final hasImage =
                        selectedImageBytes != null ||
                        currentImageUrl.isNotEmpty;
                    if (!hasImage ||
                        bannerNameController.text.trim().isEmpty ||
                        bannerUrlController.text.trim().isEmpty ||
                        descriptionController.text.trim().isEmpty ||
                        durationController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }
                    if (duration == null || duration <= 0) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Duration must be a positive number'),
                        ),
                      );
                      return;
                    }

                    isSubmittingFlow = true;
                    if (selectedImageBytes != null && selectedImage != null) {
                      setDialogState(() {
                        isUploading = true;
                        isSaving = false;
                      });
                      context.read<S3UploadBloc>().add(
                        UploadFile(
                          bytes: selectedImageBytes!,
                          filename: selectedImage!.name,
                          folder: 'Banners',
                        ),
                      );
                      return;
                    }

                    submitWithImageUrl(currentImageUrl, setDialogState);
                  },
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      bannerNameController.dispose();
      bannerUrlController.dispose();
      durationController.dispose();
      descriptionController.dispose();
    });
  }

  void _openDeleteBannerDialog(AdBannerModel banner) {
    bool isDeleting = false;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocListener<AdBannerBloc, AdBannerState>(
              listener: (context, state) {
                if (!isDeleting) return;
                if (state is AdBannerLoaded || state is AdBannerError) {
                  isDeleting = false;
                  Navigator.pop(dialogContext);
                }
              },
              child: AdminActionDialog(
                title: 'Delete Banner',
                submitText: 'Delete',
                submitLoading: isDeleting,
                submitEnabled: !isDeleting,
                child: DynamicText(
                  'Are you sure you want to delete this banner?',
                  style: AppThemes.f18w400,
                ),
                onSubmit: () {
                  setDialogState(() {
                    isDeleting = true;
                  });
                  _pendingMutationAction = 'delete';
                  context.read<AdBannerBloc>().add(DeleteBanner(banner.id));
                },
              ),
            );
          },
        );
      },
    );
  }

  void _openAddOfferDialog({AdBannerModel? existing}) {
    final isEditMode = existing != null;
    List<XFile> selectedImages = [];
    List<Uint8List> selectedImageBytesList = [];
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descController = TextEditingController(
      text: existing?.description ?? '',
    );
    final urlController = TextEditingController(text: existing?.linkUrl ?? '');
    final durationController = TextEditingController(
      text: existing == null ? '' : existing.durationDays.toString(),
    );
    String currentImageCsv = existing?.imageUrl ?? '';

    bool isUploading = false;
    bool isSaving = false;
    bool isSubmittingFlow = false;
    int uploadIndex = 0;
    List<String> uploadedUrls = [];

    void submitWithImageUrls(
      String imageUrlCsv,
      void Function(void Function()) setDialogState,
    ) {
      final duration = int.tryParse(durationController.text.trim());
      if (duration == null || duration <= 0) {
        isSubmittingFlow = false;
        setDialogState(() {
          isUploading = false;
          isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Duration must be a positive number')),
        );
        return;
      }

      String finalImagesUrl = '';
      if (imageUrlCsv.isNotEmpty && currentImageCsv.isNotEmpty) {
        finalImagesUrl = '$currentImageCsv,$imageUrlCsv';
      } else if (imageUrlCsv.isNotEmpty) {
        finalImagesUrl = imageUrlCsv;
      } else if (currentImageCsv.isNotEmpty) {
        finalImagesUrl = currentImageCsv;
      }

      final model = AdBannerModel(
        id: existing?.id ?? '',
        name: nameController.text.trim(),
        type: 'offers',
        durationDays: duration,
        imageUrl: finalImagesUrl,
        linkUrl: urlController.text.trim(),
        description: descController.text.trim(),
        createdAt: existing?.createdAt,
        updatedAt: existing?.updatedAt,
      );

      setDialogState(() {
        isUploading = false;
        isSaving = true;
      });

      _pendingMutationAction = isEditMode ? 'update' : 'create';
      if (isEditMode) {
        context.read<AdBannerBloc>().add(
          UpdateBanner(id: existing.id, banner: model),
        );
      } else {
        context.read<AdBannerBloc>().add(CreateBanner(model));
      }
    }

    List<String> currentImageUrls = currentImageCsv.isNotEmpty
        ? currentImageCsv.split(',').map((e) => e.trim()).toList()
        : [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocListener<S3UploadBloc, S3UploadState>(
              listener: (context, state) {
                if (!isSubmittingFlow || !isUploading) return;

                if (state is S3UploadFailure) {
                  isSubmittingFlow = false;
                  setDialogState(() {
                    isUploading = false;
                    isSaving = false;
                  });
                  ScaffoldMessenger.of(
                    dialogContext,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }

                if (state is S3UploadSuccess) {
                  uploadedUrls.add(state.result.url);
                  uploadIndex++;
                  if (uploadIndex < selectedImages.length) {
                    final file = selectedImages[uploadIndex];
                    context.read<S3UploadBloc>().add(
                      UploadFile(
                        bytes: selectedImageBytesList[uploadIndex],
                        filename: file.name,
                        folder: 'Offers',
                      ),
                    );
                  } else {
                    submitWithImageUrls(uploadedUrls.join(','), setDialogState);
                  }
                }
              },
              child: BlocListener<AdBannerBloc, AdBannerState>(
                listener: (context, state) {
                  if (!isSubmittingFlow) return;

                  if (state is AdBannerError) {
                    isSubmittingFlow = false;
                    setDialogState(() {
                      isUploading = false;
                      isSaving = false;
                    });
                  }

                  if (state is AdBannerLoaded) {
                    isSubmittingFlow = false;
                    Navigator.pop(dialogContext);
                  }
                },
                child: AdminActionDialog(
                  title: isEditMode ? 'Edit Offer' : 'Add Offer',
                  submitText: isEditMode ? 'Update' : 'Create',
                  submitColor: AppColors.primaryColor,
                  submitLoading: isUploading || isSaving,
                  submitEnabled: !(isUploading || isSaving),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(dialogContext).size.height * 0.7,
                      maxWidth: 600,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DynamicText(
                            'Offer Images (Multiple)',
                            style: AppThemes.f16w500,
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
                                    (selectedImages.isNotEmpty ||
                                            currentImageUrls.isNotEmpty)
                                        ? '${selectedImages.length + currentImageUrls.length} images selected'
                                        : 'No images selected',
                                    style: AppThemes.f16w400,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.image_outlined),
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final files = await picker.pickMultiImage();
                                  if (files.isNotEmpty) {
                                    List<Uint8List> byteList = [];
                                    for (var file in files) {
                                      byteList.add(await file.readAsBytes());
                                    }
                                    setDialogState(() {
                                      selectedImages.addAll(files);
                                      selectedImageBytesList.addAll(byteList);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                          if (currentImageUrls.isNotEmpty ||
                              selectedImages.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                ...currentImageUrls.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final url = entry.value;
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 120, // Portrait
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xFFE1E1E1),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            url,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: -6,
                                        top: -6,
                                        child: InkWell(
                                          onTap: () {
                                            setDialogState(() {
                                              currentImageUrls.removeAt(index);
                                              currentImageCsv = currentImageUrls
                                                  .join(',');
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                ...selectedImages.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final file = entry.value;
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 120, // Portrait
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xFFE1E1E1),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            file.path,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: -6,
                                        top: -6,
                                        child: InkWell(
                                          onTap: () {
                                            setDialogState(() {
                                              selectedImages.removeAt(index);
                                              selectedImageBytesList.removeAt(
                                                index,
                                              );
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          DynamicText('Offer Name', style: AppThemes.f16w500),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: nameController,
                            labelText: 'Offer Name',
                          ),
                          const SizedBox(height: 12),
                          DynamicText(
                            'Offer Link URL',
                            style: AppThemes.f16w500,
                          ),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: urlController,
                            labelText: 'Offer Link URL',
                          ),
                          const SizedBox(height: 12),
                          DynamicText(
                            'Duration in days',
                            style: AppThemes.f16w500,
                          ),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: durationController,
                            labelText: 'Duration in days',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 12),
                          DynamicText('Description', style: AppThemes.f16w500),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: descController,
                            labelText: 'Description',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  onSubmit: () {
                    final duration = int.tryParse(
                      durationController.text.trim(),
                    );
                    if (nameController.text.trim().isEmpty ||
                        descController.text.trim().isEmpty ||
                        urlController.text.trim().isEmpty ||
                        durationController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }
                    if (duration == null || duration <= 0) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Duration must be a positive number'),
                        ),
                      );
                      return;
                    }
                    if (selectedImages.isEmpty && currentImageUrls.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Please select at least one image'),
                        ),
                      );
                      return;
                    }
                    if (selectedImages.isEmpty) {
                      isSubmittingFlow = true;
                      submitWithImageUrls('', setDialogState);
                      return;
                    }

                    isSubmittingFlow = true;
                    setDialogState(() {
                      isUploading = true;
                      isSaving = false;
                      uploadIndex = 0;
                      uploadedUrls = [];
                    });

                    final file = selectedImages[0];
                    context.read<S3UploadBloc>().add(
                      UploadFile(
                        bytes: selectedImageBytesList[0],
                        filename: file.name,
                        folder: 'Offers',
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBannerList(List<AdBannerModel> banners) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: banners.length,
      itemBuilder: (context, index) {
        final item = banners[index];
        return AdBannerListingWidget(
          name: item.name,
          imageUrl: item.imageUrl,
          linkUrl: item.linkUrl,
          duration: '${item.durationDays} Days',
          isVertical: item.type == 'offer' || item.type == 'offers',
          onPreviewTap: () => _showBannerPreviewDialog(item.imageUrl),
          onLinkTap: () => _openBannerLink(item.linkUrl),
          onEdit: () {
            if (item.type == 'offers' || item.type == 'offer') {
              _openAddOfferDialog(existing: item);
            } else {
              _openBannerDialog(existing: item);
            }
          },
          onDelete: () => _openDeleteBannerDialog(item),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdBannerBloc, AdBannerState>(
      listener: (context, state) {
        if (_pendingMutationAction == null) return;

        if (state is AdBannerLoaded) {
          _showMutationSuccessMessage(_pendingMutationAction!);
          _pendingMutationAction = null;
        }

        if (state is AdBannerError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          _pendingMutationAction = null;
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
                      'Ad Banner Management',
                      style: AppThemes.f28w600,
                    ),
                    const SizedBox(height: 10),
                    DynamicText(
                      'Manage promotion plan and pricing',
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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 24,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xFFE1E1E1),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: PopupMenuButton<String>(
                                      offset: const Offset(0, 40),
                                      color: Colors.white,
                                      onSelected: (value) {
                                        setState(() {
                                          _currentFilter = value;
                                        });
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'all',
                                          child: Text('All'),
                                        ),
                                        PopupMenuItem(
                                          value: 'offers',
                                          child: Text('Offers'),
                                        ),
                                        PopupMenuItem(
                                          value: 'carousel',
                                          child: Text('Ad Banner'),
                                        ),
                                      ],
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.filter_list,
                                              color: AppColors.primaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            DynamicText(
                                              _currentFilter == 'offers'
                                                  ? 'Offers'
                                                  : _currentFilter == 'carousel'
                                                  ? 'Ad Banner'
                                                  : 'Filter',
                                              style: AppThemes.f16w500,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 160,
                                    child: CustomButton(
                                      text: '+ Add Offer',
                                      onPressed: () => _openAddOfferDialog(),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 160,
                                    child: CustomButton(
                                      text: '+ Add Banner',
                                      onPressed: () => _openBannerDialog(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              border: Border.all(
                                color: const Color(0xFFE1E1E1),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  SizedBox(width: 40),
                                  Expanded(
                                    flex: 2,
                                    child: DynamicText(
                                      'Banner Preview',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: DynamicText(
                                        'Banner Name',
                                        style: AppThemes.f20w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: DynamicText(
                                        'Link URL',
                                        style: AppThemes.f20w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: DynamicText(
                                        'Duration',
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
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          BlocBuilder<AdBannerBloc, AdBannerState>(
                            builder: (context, state) {
                              if (state is AdBannerLoading) {
                                return Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: List.generate(
                                      6,
                                      (index) => Padding(
                                        padding: EdgeInsets.only(
                                          bottom: index == 5 ? 0 : 20,
                                        ),
                                        child: const _AdBannerShimmerRow(),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              if (state is AdBannerMutating) {
                                final shimmerCount = state.banners.isEmpty
                                    ? 1
                                    : state.banners.length;
                                return Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: List.generate(
                                      shimmerCount,
                                      (index) => Padding(
                                        padding: EdgeInsets.only(
                                          bottom: index == shimmerCount - 1
                                              ? 0
                                              : 20,
                                        ),
                                        child: const _AdBannerShimmerRow(),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              if (state is AdBannerLoaded) {
                                final filteredBanners = state.banners.where((
                                  b,
                                ) {
                                  if (_currentFilter == 'offers')
                                    return b.type == 'offer' ||
                                        b.type == 'offers';
                                  if (_currentFilter == 'carousel')
                                    return b.type == 'carousel';
                                  return true;
                                }).toList();

                                if (filteredBanners.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Center(
                                      child: DynamicText(
                                        'No banners available',
                                      ),
                                    ),
                                  );
                                }
                                return _buildBannerList(filteredBanners);
                              }

                              if (state is AdBannerError) {
                                if (state.banners.isNotEmpty) {
                                  final filteredBanners = state.banners.where((
                                    b,
                                  ) {
                                    if (_currentFilter == 'offers')
                                      return b.type == 'offer' ||
                                          b.type == 'offers';
                                    if (_currentFilter == 'carousel')
                                      return b.type == 'carousel';
                                    return true;
                                  }).toList();
                                  return _buildBannerList(filteredBanners);
                                }
                                return Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: DynamicText(state.message),
                                );
                              }

                              return const SizedBox();
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 24,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 160,
                                    child: CustomButton(
                                      text: '+ Add Offer',
                                      onPressed: () => _openAddOfferDialog(),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 160,
                                    child: CustomButton(
                                      text: '+ Add Banner',
                                      onPressed: () => _openBannerDialog(),
                                    ),
                                  ),
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
    );
  }
}

class _AdBannerShimmerRow extends StatelessWidget {
  const _AdBannerShimmerRow();

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
            children: const [
              SizedBox(width: 40),
              Expanded(flex: 2, child: _ShimmerBox(width: 120, height: 92)),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              SizedBox(width: 20),
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

  const _ShimmerBox({required this.width, required this.height});

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

class OfferCarouselDialog extends StatefulWidget {
  final List<String> urls;
  const OfferCarouselDialog({super.key, required this.urls});

  @override
  State<OfferCarouselDialog> createState() => _OfferCarouselDialogState();
}

class _OfferCarouselDialogState extends State<OfferCarouselDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: widget.urls.length == 1
                  ? _buildImage(widget.urls.first)
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: widget.urls.length,
                      onPageChanged: (idx) {
                        setState(() {
                          _currentPage = idx;
                        });
                      },
                      itemBuilder: (context, index) {
                        return _buildImage(widget.urls[index]);
                      },
                    ),
            ),
          ),
          if (widget.urls.length > 1) ...[
            // Left Arrow
            Positioned(
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  if (_currentPage > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _pageController.animateToPage(
                      widget.urls.length - 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
            // Right Arrow
            Positioned(
              right: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  if (_currentPage < widget.urls.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
            // Pagination Dots
            Positioned(
              bottom: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.urls.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primaryColor
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
          // Close Button
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 60,
            color: Colors.white70,
          ),
        );
      },
    );
  }
}
