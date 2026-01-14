import 'package:_96sooq_admin/constants/themes.dart';
import 'package:flutter/material.dart';

class PaymentsListingWidget extends StatelessWidget {
  final String transactionId;
  final String name;
  final String category;
  final String amount;
  final String date;
  final String status;
  const PaymentsListingWidget({
    super.key,
    required this.transactionId,
    required this.status,
    required this.name,
    required this.category,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Success';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          SizedBox(width: 40),
          Expanded(
            flex: 1,
            child: Text(
              transactionId,
              style: AppThemes.f20w300,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(name, style: AppThemes.f20w300, maxLines: 2),
          ),
          Expanded(
            flex: 1,
            child: Text(category, style: AppThemes.f20w300, maxLines: 2),
          ),
          Expanded(
            flex: 1,
            child: Center(child: Text(amount, style: AppThemes.f20w300, maxLines: 1,overflow: TextOverflow.ellipsis,)),
          ),
          Expanded(
            flex: 1,
            child: Center(child: Text(date, style: AppThemes.f20w300, maxLines: 1,overflow: TextOverflow.ellipsis,)),
          ),
          Expanded(flex: 1, child: _StatusChip(isActive: isActive)),
          SizedBox(width: 24,)
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;

  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDBFCE7) : const Color(0xFFFFE2E2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          isActive ? 'Success' : 'Failed',
          style: AppThemes.f20w400.copyWith(
            color: isActive ? const Color(0xFF1E8E4E) : Color(0xFFF93939),
          ),
        ),
      ),
    );
  }
}
