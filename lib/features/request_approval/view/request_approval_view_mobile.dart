import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/auth/widgets/custom_textformfield.dart';
import 'package:_96sooq_admin/features/shared/global_widgets/custom_button_widgets.dart';
import 'package:_96sooq_admin/features/request_approval/bloc/listing_bloc.dart';
import 'package:_96sooq_admin/features/home/bloc/dashboard_bloc.dart';
import 'package:_96sooq_admin/features/home/bloc/dashboard_event.dart';
import 'package:_96sooq_admin/features/home/bloc/dashboard_state.dart';
import 'package:_96sooq_admin/features/request_approval/widgets/listing_details_widget.dart';
import 'package:_96sooq_admin/features/request_approval/widgets/request_approval_row_widget.dart';
import 'package:_96sooq_admin/features/request_approval/widgets/request_approval_section_card.dart';
import 'package:_96sooq_admin/features/request_approval/model/listing_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class RequestApprovalViewMobile extends StatefulWidget {
  const RequestApprovalViewMobile({super.key});

  @override
  State<RequestApprovalViewMobile> createState() =>
      _RequestApprovalViewMobileState();
}

class _RequestApprovalViewMobileState extends State<RequestApprovalViewMobile> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String selectedStatus = 'pending_approval';
  bool _isWaitingForDashboard = false;

  @override
  void initState() {
    super.initState();
    _fetchListings();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<ListingBloc>().add(LoadMoreListings(status: selectedStatus));
    }
  }

  void _fetchListings() {
    context.read<ListingBloc>().add(LoadListings(status: selectedStatus));
  }

  RequestApprovalRowData _mapListingToRow(ListingModel listing) {
    final isIndividual = listing.sellerType.toLowerCase() == 'individual';
    final displayName = isIndividual
        ? (listing.userName ?? 'Unknown Seller')
        : (listing.storeName ?? 'Unknown Store');
    return RequestApprovalRowData(
      type: RequestApprovalType.listing,
      name: listing.title,
      sellerName: displayName,
      dateSubmitted: listing.createdAt.split('T').first,
      status: listing.status == 'active'
          ? RequestApprovalStatus.approved
          : RequestApprovalStatus.pending,
      listing: listing,
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DynamicText('Request Approval', style: AppThemes.f22w600),
          const SizedBox(height: 8),
          DynamicText(
            'Review and approve store and promotion request',
            style: AppThemes.f16w400,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomTextFormField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    labelText: 'Search...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF99A1Af),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 18,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'pending_approval',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedStatus = val);
                        _fetchListings();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          BlocConsumer<ListingBloc, ListingState>(
            listener: (context, state) {
              if (state is ListingActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                // Start waiting for the dashboard, then fetch listings
                _isWaitingForDashboard = true;
                context.read<DashboardBloc>().add(LoadDashboardMetrics());
              } else if (state is ListingActionError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return BlocListener<DashboardBloc, DashboardState>(
                listener: (context, dashboardState) {
                  if (_isWaitingForDashboard &&
                      dashboardState is DashboardLoaded) {
                    _isWaitingForDashboard = false;
                    // Dashboard loaded, now fetch listings
                    context.read<ListingBloc>().add(
                      LoadListings(status: selectedStatus, isRefresh: true),
                    );
                  }
                },
                child: _buildListingContent(context, state, query),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildListingContent(
      BuildContext context, ListingState state, String query) {
    if (state is ListingLoading ||
        state is ListingActionLoading ||
        state is ListingActionSuccess) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                );
              } else if (state is ListingLoaded) {
                final filteredListings = state.listings.where((l) {
                  if (query.isEmpty) return true;
                  return l.title.toLowerCase().contains(query) ||
                      (l.storeName ?? '').toLowerCase().contains(query) ||
                      (l.userName ?? '').toLowerCase().contains(query);
                }).toList();

                if (filteredListings.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: DynamicText(
                        "No data found.",
                        style: AppThemes.f16w400.copyWith(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final rows = filteredListings.map(_mapListingToRow).toList();
                final dashboardState = context.watch<DashboardBloc>().state;
                int pendingRequestsCount = 0;
                if (dashboardState is DashboardLoaded) {
                  pendingRequestsCount = dashboardState.metrics.pendingRequests;
                }

                final Widget sectionCard = _ScrollableSectionCard(
                  title: selectedStatus == 'pending_approval'
                      ? 'Pending Approval ($pendingRequestsCount)'
                      : 'Active Listings',
                  rows: rows,
                  controller: _scrollController,
                  showBothActions: selectedStatus == 'pending_approval',
                  onRowTap: (rowData) {
                    if (rowData.listing != null) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => DraggableScrollableSheet(
                          initialChildSize: 0.85,
                          minChildSize: 0.5,
                          maxChildSize: 0.95,
                          expand: false,
                          builder: (_, scrollController) => Column(
                            children: [
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                  child: ListingDetailsWidget(
                                    listing: rowData.listing!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  onApproveTap: (rowData) =>
                      _showApproveDialog(context, rowData),
                  onRejectTap: (rowData) => _showRejectDialog(context, rowData),
                );

                return Column(
                  children: [
                    sectionCard,
                    if (state.listings.isNotEmpty && !state.hasReachedMax)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  ],
                );
              } else if (state is ListingError) {
                return Center(
                  child: Text(
                    'Error loading listings: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

      return const SizedBox.shrink();
    }
  }

  void _showApproveDialog(BuildContext context, RequestApprovalRowData rowData) {
    if (rowData.listing == null) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: DynamicText('Approve Listing', style: AppThemes.f20w600),
        content: DynamicText(
          'Are you sure you want to approve this listing?',
          style: AppThemes.f16w400,
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: DynamicText('Cancel', style: AppThemes.f16w600),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                height: 40,
                child: CustomButton(
                  text: 'Approve',
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.read<ListingBloc>().add(
                      ApproveListing(id: rowData.listing!.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, RequestApprovalRowData rowData) {
    if (rowData.listing == null) return;
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: DynamicText('Reject Listing', style: AppThemes.f20w600),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DynamicText(
                'Are you sure you want to reject this listing?',
                style: AppThemes.f16w400,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                controller: reasonController,
                labelText: 'Rejection Reason',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Reason is mandatory';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: DynamicText('Cancel', style: AppThemes.f16w600),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                height: 40,
                child: CustomButton(
                  text: 'Reject',
                  color: Colors.red,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(ctx);
                      context.read<ListingBloc>().add(
                        RejectListing(
                          id: rowData.listing!.id,
                          reason: reasonController.text.trim(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

class _ScrollableSectionCard extends StatelessWidget {
  final String title;
  final List<RequestApprovalRowData> rows;
  final ScrollController controller;
  final bool showBothActions;
  final Function(RequestApprovalRowData)? onRowTap;
  final Function(RequestApprovalRowData)? onApproveTap;
  final Function(RequestApprovalRowData)? onRejectTap;

  const _ScrollableSectionCard({
    required this.title,
    required this.rows,
    required this.controller,
    this.showBothActions = false,
    this.onRowTap,
    this.onApproveTap,
    this.onRejectTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E1E1)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: DynamicText(title, style: AppThemes.f18w600),
            ),
          ),
          Scrollbar(
            controller: controller,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: controller,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 760,
                child: RequestApprovalSectionCard(
                  showContainer: false,
                  rows: rows,
                  showBothActions: showBothActions,
                  isCompact: true,
                  onRowTap: onRowTap,
                  onApproveTap: onApproveTap,
                  onRejectTap: onRejectTap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
