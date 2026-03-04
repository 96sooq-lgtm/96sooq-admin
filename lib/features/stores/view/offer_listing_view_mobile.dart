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

class OfferListingViewMobile extends StatefulWidget {
  const OfferListingViewMobile({super.key});

  @override
  State<OfferListingViewMobile> createState() => _OfferListingViewMobileState();
}

class _OfferListingViewMobileState extends State<OfferListingViewMobile> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _tableScrollController = ScrollController();
  final ScrollController _listScrollController = ScrollController();
  bool _hasLoadedStores = false;

  @override
  void initState() {
    super.initState();
    if (!_hasLoadedStores) {
      _hasLoadedStores = true;
      context.read<StoreBloc>().add(LoadStores());
    }
    _tableScrollController.addListener(_onScroll);
    _listScrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
  }

  void _onScroll() {
    if ((_tableScrollController.hasClients &&
            _tableScrollController.position.pixels >=
                _tableScrollController.position.maxScrollExtent - 200) ||
        (_listScrollController.hasClients &&
            _listScrollController.position.pixels >=
                _listScrollController.position.maxScrollExtent - 200)) {
      context.read<StoreBloc>().add(LoadMoreStores());
    }
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    searchController.dispose();
    _tableScrollController.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      body: BlocBuilder<StoreBloc, StoreState>(
        builder: (context, state) {
          return CustomScrollView(
            controller: _listScrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      DynamicText('Stores', style: AppThemes.f20w600),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: CustomTextFormField(
                          controller: searchController,
                          labelText: 'Search store name..',
                          fillColor: Colors.white,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF99A1Af),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE1E1E1)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Scrollbar(
                            controller: _tableScrollController,
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              controller: _tableScrollController,
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: 860,
                                child: Column(
                                  children: [
                                    _StoreTableHeader(),
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
                                          final filteredStores = state.stores
                                              .where((store) {
                                                if (query.isEmpty) return true;
                                                return store.name
                                                        .toLowerCase()
                                                        .contains(query) ||
                                                    store.nameAr
                                                        .toLowerCase()
                                                        .contains(query);
                                              })
                                              .toList();

                                          if (filteredStores.isEmpty) {
                                            return const Padding(
                                              padding: EdgeInsets.all(20),
                                              child: Center(
                                                child: DynamicText(
                                                  'No results found',
                                                ),
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
                            ),
                          ),
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

class _StoreTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE1E1E1)),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            SizedBox(width: 40),
            Expanded(
              flex: 1,
              child: DynamicText('Logo', style: AppThemes.f14w600),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: DynamicText('Store name', style: AppThemes.f14w600),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: DynamicText('Status', style: AppThemes.f14w600),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: DynamicText('Actions', style: AppThemes.f14w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
