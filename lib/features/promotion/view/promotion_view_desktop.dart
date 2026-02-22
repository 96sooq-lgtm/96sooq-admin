import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/enums/subsciption_enums.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_bloc.dart';
import 'package:_96sooq_admin/core/bloc/language/bloc/language_state.dart';
import 'package:_96sooq_admin/core/bloc/language/translation_service.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/promotion/widgets/promotion_slab_listing_widget.dart';
import 'package:_96sooq_admin/features/category/widgets/add_category_popup.dart';
import 'package:_96sooq_admin/features/promotion/bloc/subscription_bloc.dart';
import 'package:_96sooq_admin/features/promotion/model/subscription_model.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PromotionViewDesktop extends StatefulWidget {
  const PromotionViewDesktop({super.key});

  @override
  State<PromotionViewDesktop> createState() => _PromotionViewDesktopState();
}

class _PromotionViewDesktopState extends State<PromotionViewDesktop> {
  bool _hasLoaded = false;
  static final RegExp _descriptionPointPrefix = RegExp(r'^\d+\.\s');

  @override
  void initState() {
    super.initState();
    if (!_hasLoaded) {
      _hasLoaded = true;
      context.read<SubscriptionBloc>().add(LoadSubscriptions());
    }
  }

  String _targetAudienceLabel(String? value) {
    switch (value) {
      case 'individual':
        return 'Individual';
      case 'store':
        return 'Store';
      case 'everyone':
        return 'Everyone';
      default:
        return '-';
    }
  }

  List<String> _extractPointLines(
    String raw, {
    bool keepEmpty = true,
    int maxLines = 5,
  }) {
    final lines = raw.split('\n');
    final result = <String>[];
    for (final line in lines) {
      final cleaned = line.replaceFirst(_descriptionPointPrefix, '');
      if (!keepEmpty && cleaned.trim().isEmpty) {
        continue;
      }
      result.add(cleaned);
      if (result.length >= maxLines) {
        break;
      }
    }
    if (result.isEmpty) {
      result.add('');
    }
    return result;
  }

  String _toNumberedLines(List<String> lines) {
    return List.generate(
      lines.length,
      (index) => '${index + 1}. ${lines[index]}',
    ).join('\n');
  }

  String _normalizeNumberedDescription(String raw, {int maxLines = 5}) {
    final lines = _extractPointLines(raw, keepEmpty: true, maxLines: maxLines);
    return _toNumberedLines(lines);
  }

  int _descriptionPrefixLength(String line) {
    final match = _descriptionPointPrefix.firstMatch(line);
    return match?.group(0)?.length ?? 0;
  }

  ({int line, int column}) _descriptionLineColumnFromOffset(
    String text,
    int offset,
  ) {
    final lines = text.split('\n');
    int consumed = 0;
    for (int i = 0; i < lines.length; i++) {
      final lineLength = lines[i].length;
      final lineEnd = consumed + lineLength;
      if (offset <= lineEnd) {
        return (line: i, column: (offset - consumed).clamp(0, lineLength));
      }
      consumed = lineEnd + 1;
    }
    final lastLine = lines.isEmpty ? 0 : lines.length - 1;
    final lastColumn = lines.isEmpty ? 0 : lines[lastLine].length;
    return (line: lastLine, column: lastColumn);
  }

  int _descriptionOffsetFromLineAndColumn(
    List<String> contentLines,
    int targetLine,
    int targetColumn,
  ) {
    int offset = 0;
    for (int i = 0; i < targetLine; i++) {
      final numberedLine = '${i + 1}. ${contentLines[i]}';
      offset += numberedLine.length + 1;
    }
    final prefixLength = '${targetLine + 1}. '.length;
    final safeColumn = targetColumn.clamp(0, contentLines[targetLine].length);
    offset += prefixLength + safeColumn;
    return offset;
  }

  TextEditingValue _applyDescriptionEdit(
    TextEditingValue oldValue,
    TextEditingValue newValue, {
    int maxLines = 5,
  }) {
    if (oldValue == newValue) {
      return newValue;
    }
    final displayLines = newValue.text.split('\n');
    final selectionOffset = newValue.selection.baseOffset < 0
        ? newValue.text.length
        : newValue.selection.baseOffset;
    final cursor = _descriptionLineColumnFromOffset(
      newValue.text,
      selectionOffset,
    );
    final safeDisplayLine = cursor.line.clamp(0, displayLines.length - 1);
    final safeDisplayColumn = cursor.column.clamp(
      0,
      displayLines[safeDisplayLine].length,
    );
    final currentPrefixLength = _descriptionPrefixLength(
      displayLines[safeDisplayLine],
    );
    final logicalColumn = (safeDisplayColumn - currentPrefixLength).clamp(
      0,
      displayLines[safeDisplayLine].length,
    );

    final contentLines = displayLines
        .map((line) => line.replaceFirst(_descriptionPointPrefix, ''))
        .toList();
    final limitedContentLines = contentLines.take(maxLines).toList();
    if (limitedContentLines.isEmpty) {
      limitedContentLines.add('');
    }

    int? forcedTargetLine;
    int? forcedTargetColumn;
    final isBackspaceDeletion =
        oldValue.selection.isCollapsed &&
        newValue.selection.isCollapsed &&
        oldValue.text.length == newValue.text.length + 1 &&
        oldValue.selection.baseOffset == newValue.selection.baseOffset + 1;
    if (isBackspaceDeletion) {
      final oldOffset = oldValue.selection.baseOffset;
      final oldCursor = _descriptionLineColumnFromOffset(
        oldValue.text,
        oldOffset,
      );
      final oldLines = oldValue.text.split('\n');
      if (oldCursor.line >= 0 && oldCursor.line < oldLines.length) {
        final oldLine = oldLines[oldCursor.line];
        final oldContent = oldLine.replaceFirst(_descriptionPointPrefix, '');
        final oldPrefixLength = _descriptionPrefixLength(oldLine);
        final deletingPrefixOnEmptyPoint =
            oldContent.isEmpty && oldCursor.column <= oldPrefixLength;
        if (deletingPrefixOnEmptyPoint && limitedContentLines.length > 1) {
          final removeAt = oldCursor.line.clamp(
            0,
            limitedContentLines.length - 1,
          );
          limitedContentLines.removeAt(removeAt);
          if (limitedContentLines.isEmpty) {
            limitedContentLines.add('');
          }
          forcedTargetLine = (removeAt - 1).clamp(
            0,
            limitedContentLines.length - 1,
          );
          forcedTargetColumn = limitedContentLines[forcedTargetLine].length;
        }
      }
    }

    final targetLine =
        forcedTargetLine ??
        safeDisplayLine.clamp(0, limitedContentLines.length - 1);
    final targetColumn =
        forcedTargetColumn ??
        logicalColumn.clamp(0, limitedContentLines[targetLine].length);
    final normalizedText = _toNumberedLines(limitedContentLines);
    final mappedOffset = _descriptionOffsetFromLineAndColumn(
      limitedContentLines,
      targetLine,
      targetColumn,
    );

    return TextEditingValue(
      text: normalizedText,
      selection: TextSelection.collapsed(offset: mappedOffset),
    );
  }

  void _openDeleteSubscriptionDialog(String id) {
    bool isDeleting = false;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocListener<SubscriptionBloc, SubscriptionState>(
              listener: (context, state) {
                if (!isDeleting) return;
                if (state is SubscriptionError) {
                  ScaffoldMessenger.of(
                    this.context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                  this.context.read<SubscriptionBloc>().add(
                    LoadSubscriptions(),
                  );
                }
                if (state is SubscriptionLoaded || state is SubscriptionError) {
                  isDeleting = false;
                  Navigator.pop(dialogContext);
                }
              },
              child: AdminActionDialog(
                title: "Delete Subscription",
                submitText: "Delete",
                submitLoading: isDeleting,
                submitEnabled: !isDeleting,
                submitColor: Colors.black,
                child: DynamicText(
                  "Are you sure you want to delete this subscription?",
                  style: AppThemes.f18w400,
                ),
                onSubmit: () {
                  setDialogState(() {
                    isDeleting = true;
                  });
                  context.read<SubscriptionBloc>().add(DeleteSubscription(id));
                },
              ),
            );
          },
        );
      },
    );
  }

  void _openSubscriptionDialog({SubscriptionModel? existing}) {
    final isEditMode = existing != null;
    final nameEnController = TextEditingController(
      text: existing?.nameEn ?? '',
    );
    final nameArController = TextEditingController(
      text: existing?.nameAr ?? '',
    );
    final priceController = TextEditingController(
      text: existing == null ? '' : existing.price.toInt().toString(),
    );
    final durationController = TextEditingController(
      text: existing == null ? '' : existing.durationDays.toString(),
    );
    final quotaController = TextEditingController(
      text: existing == null ? '0' : existing.quota.toString(),
    );
    SubscriptionType planTypeValue =
        existing?.type ?? SubscriptionType.productListing;
    String statusValue = (existing?.isActive ?? true) ? "Active" : "Inactive";
    final descriptionController = TextEditingController(
      text: _normalizeNumberedDescription(existing?.description ?? '1. '),
    );
    String? targetAudienceValue =
        planTypeValue == SubscriptionType.productListing
        ? (existing?.targetAudience ?? 'individual')
        : null;
    bool isBestValue = existing?.isBestValue ?? false;
    bool isSaving = false;
    bool isNormalizingDescription = false;
    TextEditingValue previousDescriptionValue = descriptionController.value;

    void normalizeDescriptionListener() {
      if (isNormalizingDescription) {
        return;
      }
      final currentValue = descriptionController.value;
      final normalizedValue = _applyDescriptionEdit(
        previousDescriptionValue,
        currentValue,
      );
      if (normalizedValue.text == currentValue.text &&
          normalizedValue.selection.baseOffset ==
              currentValue.selection.baseOffset) {
        previousDescriptionValue = currentValue;
        return;
      }
      isNormalizingDescription = true;
      descriptionController.value = normalizedValue;
      isNormalizingDescription = false;
      previousDescriptionValue = descriptionController.value;
    }

    descriptionController.addListener(normalizeDescriptionListener);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocListener<SubscriptionBloc, SubscriptionState>(
              listener: (context, state) {
                if (!isSaving) return;
                if (state is SubscriptionLoaded || state is SubscriptionError) {
                  isSaving = false;
                  Navigator.pop(dialogContext);
                }
              },
              child: AdminActionDialog(
                title: isEditMode
                    ? "Edit Promotion Plan"
                    : "Create Promotion Plan",
                submitText: isEditMode ? "Update" : "Create",
                submitColor: AppColors.primaryColor,
                submitLoading: isSaving,
                submitEnabled: !isSaving,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(dialogContext).size.height * 0.65,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DynamicText("Plan Name (EN)", style: AppThemes.f16w500),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          controller: nameEnController,
                          labelText: "Plan Name (EN)",
                        ),
                        const SizedBox(height: 12),
                        DynamicText("Plan Name (AR)", style: AppThemes.f16w500),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          controller: nameArController,
                          labelText: "Plan Name (AR)",
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
                            final translated =
                                await TranslationService.translate(
                                  nameEn,
                                  'ar',
                                );
                            nameArController.text = translated;
                          },
                        ),
                        const SizedBox(height: 12),
                        DynamicText("Price", style: AppThemes.f16w500),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          controller: priceController,
                          labelText: "Price",
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        const SizedBox(height: 12),
                        DynamicText("Duration", style: AppThemes.f16w500),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          controller: durationController,
                          labelText: "Duration",
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        const SizedBox(height: 12),
                        DynamicText(
                          "Number of listings available",
                          style: AppThemes.f16w500,
                        ),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          controller: quotaController,
                          labelText: "Number of listings available",
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d*$'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DynamicText("Description", style: AppThemes.f16w500),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          controller: descriptionController,
                          labelText: "Description",
                          minLines: 1,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DynamicText("Best Value", style: AppThemes.f16w500),
                            CupertinoSwitch(
                              value: isBestValue,
                              activeTrackColor: AppColors.primaryColor,
                              onChanged: (value) {
                                setDialogState(() {
                                  isBestValue = value;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DynamicText("Type", style: AppThemes.f16w500),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<SubscriptionType>(
                          value: planTypeValue,
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
                          items: SubscriptionType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              planTypeValue = value;
                              if (planTypeValue ==
                                  SubscriptionType.productListing) {
                                targetAudienceValue ??= 'individual';
                              } else {
                                targetAudienceValue = null;
                              }
                            });
                          },
                        ),
                        if (planTypeValue ==
                            SubscriptionType.productListing) ...[
                          const SizedBox(height: 12),
                          DynamicText(
                            "Target Audience",
                            style: AppThemes.f16w500,
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: targetAudienceValue,
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
                            items: const [
                              DropdownMenuItem(
                                value: 'individual',
                                child: Text('Individual'),
                              ),
                              DropdownMenuItem(
                                value: 'store',
                                child: Text('Store'),
                              ),
                              DropdownMenuItem(
                                value: 'everyone',
                                child: Text('Everyone'),
                              ),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                targetAudienceValue = value;
                              });
                            },
                            hint: const Text('Target Audience'),
                          ),
                        ],
                        const SizedBox(height: 12),
                        DynamicText("Status", style: AppThemes.f16w500),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: statusValue,
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
                          items: const [
                            DropdownMenuItem(
                              value: "Active",
                              child: Text("Active"),
                            ),
                            DropdownMenuItem(
                              value: "Inactive",
                              child: Text("Inactive"),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              statusValue = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                onSubmit: () {
                  final normalizedDescription = _normalizeNumberedDescription(
                    descriptionController.text,
                  );
                  final hasAtLeastOnePoint = _extractPointLines(
                    normalizedDescription,
                    keepEmpty: false,
                  ).isNotEmpty;
                  if (!hasAtLeastOnePoint) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "At least one description point is required",
                        ),
                      ),
                    );
                    return;
                  }
                  if (planTypeValue == SubscriptionType.productListing &&
                      (targetAudienceValue == null ||
                          targetAudienceValue!.isEmpty)) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Target Audience is required for Product Listing",
                        ),
                      ),
                    );
                    return;
                  }
                  final price = (int.tryParse(priceController.text.trim()) ?? 0)
                      .toDouble();
                  final durationDays =
                      int.tryParse(durationController.text.trim()) ?? 0;
                  final parsedQuota = int.tryParse(quotaController.text.trim());
                  if (parsedQuota == null || parsedQuota < -1) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Quota must be -1 or a non-negative integer",
                        ),
                      ),
                    );
                    return;
                  }
                  final subscription = SubscriptionModel(
                    id: existing?.id ?? '',
                    nameEn: nameEnController.text.trim(),
                    nameAr: nameArController.text.trim(),
                    type: planTypeValue,
                    price: price,
                    durationDays: durationDays,
                    quota: parsedQuota,
                    description: normalizedDescription,
                    features: null,
                    targetAudience: targetAudienceValue,
                    isActive: statusValue == "Active",
                    isBestValue: isBestValue,
                    createdAt: null,
                  );
                  setDialogState(() {
                    isSaving = true;
                  });
                  if (isEditMode) {
                    context.read<SubscriptionBloc>().add(
                      UpdateSubscription(
                        id: existing.id,
                        subscription: subscription,
                      ),
                    );
                  } else {
                    context.read<SubscriptionBloc>().add(
                      CreateSubscription(subscription),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    ).then((_) {
      descriptionController.removeListener(normalizeDescriptionListener);
      nameEnController.dispose();
      nameArController.dispose();
      priceController.dispose();
      durationController.dispose();
      quotaController.dispose();
      descriptionController.dispose();
    });
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
                  DynamicText("Promotion Slabs", style: AppThemes.f28w600),
                  const SizedBox(height: 10),
                  DynamicText(
                    "Manage promotion plan and pricing",
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
                                Spacer(flex: 3),
                                Expanded(
                                  flex: 1,
                                  child: CustomButton(
                                    text: "+ Create plan",
                                    onPressed: () => _openSubscriptionDialog(),
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
                                  flex: 3,
                                  child: DynamicText(
                                    'Plan Name',
                                    style: AppThemes.f20w500,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: DynamicText(
                                      'Price',
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
                                      'Type',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: DynamicText(
                                      'Target Audience',
                                      style: AppThemes.f20w500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 44),
                              ],
                            ),
                          ),
                        ),
                        BlocBuilder<SubscriptionBloc, SubscriptionState>(
                          builder: (context, state) {
                            if (state is SubscriptionLoading) {
                              return Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: List.generate(
                                    8,
                                    (index) => Padding(
                                      padding: EdgeInsets.only(
                                        bottom: index == 7 ? 0 : 20,
                                      ),
                                      child: const _SubscriptionShimmerRow(),
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (state is SubscriptionLoaded) {
                              return BlocBuilder<
                                TranslationBloc,
                                TranslationState
                              >(
                                builder: (context, langState) {
                                  final isArabic = langState.isRTL;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: state.subscriptions.length,
                                    itemBuilder: (context, index) {
                                      final item = state.subscriptions[index];
                                      return PromotionSlabListingWidget(
                                        name: isArabic
                                            ? item.nameAr
                                            : item.nameEn,
                                        price: item.price.toString(),
                                        duration: "${item.durationDays} Days",
                                        type: item.type.label,
                                        isBestValue: item.isBestValue,
                                        onEdit: () => _openSubscriptionDialog(
                                          existing: item,
                                        ),
                                        targetAudienceDisplay:
                                            _targetAudienceLabel(
                                              item.targetAudience,
                                            ),
                                        onDelete: () {
                                          _openDeleteSubscriptionDialog(
                                            item.id,
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            }

                            if (state is SubscriptionError) {
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

class _SubscriptionShimmerRow extends StatelessWidget {
  const _SubscriptionShimmerRow();

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
              Expanded(
                flex: 3,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              SizedBox(width: 44),
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
