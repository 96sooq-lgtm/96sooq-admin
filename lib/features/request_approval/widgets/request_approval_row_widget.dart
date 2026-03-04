import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/request_approval/model/listing_model.dart';
import 'package:flutter/material.dart';

enum RequestApprovalStatus { pending, approved, rejected }

enum RequestApprovalType { store, promotion, seller, listing }

class RequestApprovalRowData {
  final RequestApprovalType type;
  final String name;
  final String sellerName;
  final String dateSubmitted;
  final RequestApprovalStatus status;
  final ListingModel? listing;

  const RequestApprovalRowData({
    required this.type,
    required this.name,
    required this.sellerName,
    required this.dateSubmitted,
    required this.status,
    this.listing,
  });
}

class RequestApprovalRowWidget extends StatelessWidget {
  final RequestApprovalRowData data;
  final bool isCompact;
  final bool showBothActions;
  final Function()? onTap;
  final Function()? onApproveTap;
  final Function()? onRejectTap;

  const RequestApprovalRowWidget({
    super.key,
    required this.data,
    this.isCompact = false,
    this.showBothActions = false,
    this.onTap,
    this.onApproveTap,
    this.onRejectTap,
  });

  @override
  Widget build(BuildContext context) {
    final rowPadding = isCompact ? 14.0 : 18.0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: rowPadding),
        child: Row(
          children: [
            const SizedBox(width: 40),
            Expanded(flex: 2, child: _TypeChip(type: data.type)),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: DynamicText(
                data.name,
                style: AppThemes.f20w300,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 3,
              child: DynamicText(
                data.sellerName,
                style: AppThemes.f20w300,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: DynamicText(
                data.dateSubmitted,
                style: AppThemes.f20w300,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: _ActionsCell(
                status: data.status,
                showBothActions: showBothActions,
                onApproveTap: onApproveTap,
                onRejectTap: onRejectTap,
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}

class _ActionsCell extends StatelessWidget {
  final RequestApprovalStatus status;
  final bool showBothActions;
  final VoidCallback? onApproveTap;
  final VoidCallback? onRejectTap;

  const _ActionsCell({
    required this.status,
    required this.showBothActions,
    this.onApproveTap,
    this.onRejectTap,
  });

  @override
  Widget build(BuildContext context) {
    if (showBothActions) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StatusIcon(isApproved: true, onTap: onApproveTap),
          const SizedBox(width: 14),
          _StatusIcon(isApproved: false, onTap: onRejectTap),
        ],
      );
    }

    return Center(
      child: _StatusIcon(isApproved: status == RequestApprovalStatus.approved),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final bool isApproved;
  final VoidCallback? onTap;

  const _StatusIcon({required this.isApproved, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isApproved ? const Color(0xFFE7F8EE) : const Color(0xFFFFE8E8),
        ),
        child: Icon(
          isApproved ? Icons.check : Icons.close,
          color: isApproved ? const Color(0xFF23A559) : const Color(0xFFF04438),
          size: 18,
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final RequestApprovalType type;

  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final chipData = _chipStyle(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: chipData.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DynamicText(
        chipData.label,
        style: AppThemes.f14w500.copyWith(color: chipData.foreground),
      ),
    );
  }
}

class _ChipStyle {
  final String label;
  final Color background;
  final Color foreground;

  const _ChipStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });
}

_ChipStyle _chipStyle(RequestApprovalType type) {
  switch (type) {
    case RequestApprovalType.store:
      return const _ChipStyle(
        label: 'store',
        background: Color(0xFFE7F0FF),
        foreground: Color(0xFF2E6BF2),
      );
    case RequestApprovalType.promotion:
      return const _ChipStyle(
        label: 'Promotion',
        background: Color(0xFFF1E8FF),
        foreground: Color(0xFF7C3AED),
      );
    case RequestApprovalType.seller:
      return const _ChipStyle(
        label: 'Seller',
        background: Color(0xFFE7F5FF),
        foreground: Color(0xFF1D4ED8),
      );
    case RequestApprovalType.listing:
      return const _ChipStyle(
        label: 'Listing',
        background: Color(0xFFFFF0EC),
        foreground: Color(0xFFE04F1D),
      );
  }
}
