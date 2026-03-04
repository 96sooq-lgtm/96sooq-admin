import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/stores/bloc/store_bloc.dart';
import 'package:_96sooq_admin/features/stores/bloc/store_event.dart';
import 'package:_96sooq_admin/features/stores/bloc/store_state.dart';
import 'package:_96sooq_admin/features/stores/widgets/offer_listing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OfferListingViewDesktop extends StatefulWidget {
  const OfferListingViewDesktop({super.key});

  @override
  State<OfferListingViewDesktop> createState() =>
      _OfferListingViewDesktopState();
}

class _OfferListingViewDesktopState extends State<OfferListingViewDesktop> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasLoadedStores = false;

  @override
  void initState() {
    super.initState();
    if (!_hasLoadedStores) {
      _hasLoadedStores = true;
      context.read<StoreBloc>().add(LoadStores());
    }
    _scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
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
      context.read<StoreBloc>().add(LoadMoreStores());
    }
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: BlocBuilder<StoreBloc, StoreState>(
        builder: (context, state) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 36),
                      DynamicText("Stores", style: AppThemes.f28w600),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: CustomTextFormField(
                                        controller: searchController,
                                        labelText: "Search store name..",
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          color: Color(0xFF99A1Af),
                                        ),
                                      ),
                                    ),
                                    const Spacer(flex: 2),
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
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: const [
                                    SizedBox(width: 40),
                                    Expanded(
                                      flex: 1,
                                      child: DynamicText(
                                        'Logo',
                                        style: AppThemes.f20w500,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      flex: 3,
                                      child: DynamicText(
                                        'Store name',
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
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (state is StoreLoading)
                              const Padding(
                                padding: EdgeInsets.all(40),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (state is StoreLoaded)
                              Builder(
                                builder: (context) {
                                  final filteredStores = state.stores.where((
                                    store,
                                  ) {
                                    if (query.isEmpty) return true;
                                    return store.name.toLowerCase().contains(
                                          query,
                                        ) ||
                                        store.nameAr.toLowerCase().contains(
                                          query,
                                        );
                                  }).toList();

                                  if (filteredStores.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Center(
                                        child: DynamicText('No results found'),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: filteredStores.length,
                                    itemBuilder: (context, index) {
                                      return OfferListingWidget(
                                        store: filteredStores[index],
                                      );
                                    },
                                  );
                                },
                              )
                            else if (state is StoreError)
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Center(
                                  child: DynamicText(state.message),
                                ),
                              ),

                            if (state is StoreLoaded &&
                                !state.hasReachedMax &&
                                query.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: CircularProgressIndicator(),
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
          );
        },
      ),
    );
  }
}
