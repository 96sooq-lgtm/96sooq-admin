import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/request_approval/widgets/request_approval_row_widget.dart';
import 'package:flutter/material.dart';

class RequestApprovalSectionCard extends StatelessWidget {
  final String? title;
  final List<RequestApprovalRowData> rows;
  final bool showBothActions;
  final bool isCompact;
  final bool showContainer;
  final Function(RequestApprovalRowData)? onRowTap;
  final Function(RequestApprovalRowData)? onApproveTap;
  final Function(RequestApprovalRowData)? onRejectTap;

  const RequestApprovalSectionCard({
    super.key,
    this.title,
    required this.rows,
    this.showBothActions = false,
    this.isCompact = false,
    this.showContainer = true,
    this.onRowTap,
    this.onApproveTap,
    this.onRejectTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        if (title != null && title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: DynamicText(title!, style: AppThemes.f20w600),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            border: Border.all(color: const Color(0xFFE1E1E1)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: const [
                SizedBox(width: 40),
                Expanded(
                  flex: 2,
                  child: DynamicText('Type', style: AppThemes.f20w500),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: DynamicText('Name', style: AppThemes.f20w500),
                ),
                Expanded(
                  flex: 3,
                  child: DynamicText('Seller Name', style: AppThemes.f20w500),
                ),
                Expanded(
                  flex: 2,
                  child: DynamicText(
                    'Date submitted',
                    style: AppThemes.f20w500,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: DynamicText('Actions', style: AppThemes.f20w500),
                  ),
                ),
                SizedBox(width: 24),
              ],
            ),
          ),
        ),
        if (rows.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: DynamicText('No results found')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final rowData = rows[index];
              return RequestApprovalRowWidget(
                data: rowData,
                showBothActions: showBothActions,
                isCompact: isCompact,
                onTap: onRowTap != null ? () => onRowTap!(rowData) : null,
                onApproveTap: onApproveTap != null
                    ? () => onApproveTap!(rowData)
                    : null,
                onRejectTap: onRejectTap != null
                    ? () => onRejectTap!(rowData)
                    : null,
              );
            },
          ),
      ],
    );

    if (!showContainer) {
      return content;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E1E1)),
      ),
      child: content,
    );
  }
}
