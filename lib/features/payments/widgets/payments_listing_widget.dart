import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class PaymentsListingWidget extends StatelessWidget {
  final String transactionId;
  final String name;
  final String amount;
  final String date;
  final String status;

  const PaymentsListingWidget({
    super.key,
    required this.transactionId,
    required this.status,
    required this.name,
    required this.amount,
    required this.date,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateStr).toLocal();
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          SizedBox(width: 40),
          Expanded(
            flex: 1,
            child: DynamicText(
              transactionId.substring(0, 8),
              style: AppThemes.f16w400,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: DynamicText(name, style: AppThemes.f16w400, maxLines: 2),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: DynamicText(
                amount,
                style: AppThemes.f16w500.copyWith(
                  color: AppColors.primaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: DynamicText(
                _formatDate(date),
                style: AppThemes.f16w400,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(flex: 1, child: _StatusChip(status: status)),
          SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final lowerStatus = status.toLowerCase();

    // Determine colors
    Color bgColor = const Color(0xFFF3F4F6); // Grey by default
    Color textColor = const Color(0xFF4B5563);

    if (lowerStatus == 'success' || lowerStatus == 'completed') {
      bgColor = const Color(0xFFDBFCE7);
      textColor = const Color(0xFF1E8E4E);
    } else if (lowerStatus == 'pending') {
      bgColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFD97706);
    } else if (lowerStatus == 'failed' ||
        lowerStatus == 'error' ||
        lowerStatus == 'cancelled') {
      bgColor = const Color(0xFFFFE2E2);
      textColor = const Color(0xFFF93939);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: DynamicText(
          status.toUpperCase(),
          style: AppThemes.f14w600.copyWith(color: textColor),
        ),
      ),
    );
  }
}
