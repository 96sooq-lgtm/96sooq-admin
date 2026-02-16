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
import 'package:_96sooq_admin/features/subcategory/widgets/subcategory_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PromotionViewDesktop extends StatefulWidget {
  const PromotionViewDesktop({super.key});

  @override
  State<PromotionViewDesktop> createState() => _PromotionViewDesktopState();
}

class _PromotionViewDesktopState extends State<PromotionViewDesktop> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!_hasLoaded) {
      _hasLoaded = true;
      context.read<SubscriptionBloc>().add(LoadSubscriptions());
    }
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

  void _openCreatePlanDialog() {
    final nameEnController = TextEditingController();
    final nameArController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    SubscriptionType planTypeValue = SubscriptionType.productListing;
    String statusValue = "Active";
    final descriptionController = TextEditingController();
    bool isCreating = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocListener<SubscriptionBloc, SubscriptionState>(
              listener: (context, state) {
                if (!isCreating) return;
                if (state is SubscriptionLoaded || state is SubscriptionError) {
                  isCreating = false;
                  Navigator.pop(dialogContext);
                }
              },
              child: AdminActionDialog(
                title: "Create Promotion Plan",
                submitText: "Create",
                submitColor: Colors.black,
                submitLoading: isCreating,
                submitEnabled: !isCreating,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextFormField(
                      controller: nameEnController,
                      labelText: "Plan Name (EN)",
                    ),
                    const SizedBox(height: 12),
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
                            await TranslationService.translate(nameEn, 'ar');
                        nameArController.text = translated;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: priceController,
                      labelText: "Price",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: durationController,
                      labelText: "Duration",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    CustomTextFormField(
                      controller: descriptionController,
                      labelText: "Description",
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<SubscriptionType>(
                      value: planTypeValue,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFEFEFEF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFFEFEFEF)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFFEFEFEF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFFEFEFEF)),
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
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: statusValue,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFEFEFEF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFFEFEFEF)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFFEFEFEF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFFEFEFEF)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 18,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Active", child: Text("Active")),
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
                onSubmit: () {
                  final price =
                      double.tryParse(priceController.text.trim()) ?? 0;
                  final durationDays =
                      int.tryParse(durationController.text.trim()) ?? 0;
                  final subscription = SubscriptionModel(
                    id: '',
                    nameEn: nameEnController.text.trim(),
                    nameAr: nameArController.text.trim(),
                    type: planTypeValue,
                    price: price,
                    durationDays: durationDays,
                    description: descriptionController.text.trim(),
                    features: null,
                    isActive: statusValue == "Active",
                    createdAt: null,
                  );
                  setDialogState(() {
                    isCreating = true;
                  });
                  context.read<SubscriptionBloc>().add(
                        CreateSubscription(subscription),
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
      priceController.dispose();
      durationController.dispose();
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
                                    onPressed: _openCreatePlanDialog,
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
                                  flex: 2,
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
                                        onDelete: () =>
                                            _openDeleteSubscriptionDialog(
                                          item.id,
                                        ),
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
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _ShimmerBox(width: double.infinity, height: 18),
              ),
              SizedBox(width: 40),
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
