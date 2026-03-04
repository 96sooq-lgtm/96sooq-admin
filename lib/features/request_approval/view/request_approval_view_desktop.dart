import 'package:_96sooq_admin/constants/colors.dart';
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

class RequestApprovalViewDesktop extends StatefulWidget {
  const RequestApprovalViewDesktop({super.key});

  @override
  State<RequestApprovalViewDesktop> createState() =>
      _RequestApprovalViewDesktopState();
}

class _RequestApprovalViewDesktopState
    extends State<RequestApprovalViewDesktop> {
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

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
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
                  DynamicText('Request Approval', style: AppThemes.f28w600),
                  const SizedBox(height: 10),
                  DynamicText(
                    'Review and approve store and promotion request',
                    style: AppThemes.f20w400,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 55,
                      vertical: 30,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedStatus,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE1E1E1),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE1E1E1),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE1E1E1),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'pending_approval',
                                  child: Text('Pending Approval'),
                                ),
                                DropdownMenuItem(
                                  value: 'active',
                                  child: Text('Active'),
                                ),
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
                  ),
                  const SizedBox(height: 24),
                  BlocConsumer<ListingBloc, ListingState>(
                    listener: (context, state) {
                      if (state is ListingActionSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Start waiting for the dashboard, then fetch the dashboard
                        _isWaitingForDashboard = true;
                        context.read<DashboardBloc>().add(
                          LoadDashboardMetrics(),
                        );
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
                              LoadListings(
                                  status: selectedStatus, isRefresh: true),
                            );
                          }
                        },
                        child: _buildListingContent(context, state, query),
                      );
                    },
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

  Widget _buildListingContent(
      BuildContext context, ListingState state, String query) {
    if (state is ListingLoading ||
        state is ListingActionLoading ||
        state is ListingActionSuccess) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 55),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              height: 400,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        );
                      } else if (state is ListingLoaded) {
                        final filteredListings = state.listings.where((l) {
                          if (query.isEmpty) return true;
                          return l.title.toLowerCase().contains(query) ||
                              (l.storeName ?? '').toLowerCase().contains(
                                query,
                              ) ||
                              (l.userName ?? '').toLowerCase().contains(query);
                        }).toList();

                        if (filteredListings.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 55),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: DynamicText(
                                  "No data found.",
                                  style: AppThemes.f20w400.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final rows = filteredListings
                            .map(_mapListingToRow)
                            .toList();
                        final dashboardState = context
                            .watch<DashboardBloc>()
                            .state;
                        int pendingRequestsCount = 0;
                        if (dashboardState is DashboardLoaded) {
                          pendingRequestsCount =
                              dashboardState.metrics.pendingRequests;
                        }

                        final Widget sectionCard = RequestApprovalSectionCard(
                          title: selectedStatus == 'pending_approval'
                              ? 'Pending Approval ($pendingRequestsCount)'
                              : 'Active Listings',
                          rows: rows,
                          showBothActions: selectedStatus == 'pending_approval',
                          onRowTap: (rowData) {
                            if (rowData.listing != null) {
                              showDialog(
                                context: context,
                                builder: (ctx) => Dialog(
                                  backgroundColor: Colors.transparent,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 800,
                                      maxHeight: 1000,
                                    ),
                                    child: ListingDetailsWidget(
                                      listing: rowData.listing!,
                                      onClose: () => Navigator.of(ctx).pop(),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          onApproveTap: (rowData) =>
                              _showApproveDialog(context, rowData),
                          onRejectTap: (rowData) =>
                              _showRejectDialog(context, rowData),
                        );

                        return Column(
                          children: [
                            sectionCard,
                            if (state.listings.isNotEmpty &&
                                !state.hasReachedMax)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        );
                      } else if (state is ListingError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 55),
                          child: Center(
                            child: Text(
                              'Error loading listings: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                            ),
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
