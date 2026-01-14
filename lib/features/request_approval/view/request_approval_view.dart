import 'package:_96sooq_admin/features/request_approval/view/request_approval_view_desktop.dart';
import 'package:_96sooq_admin/features/request_approval/view/request_approval_view_mobile.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class RequestApprovalView extends StatelessWidget {
  const RequestApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (context) => RequestApprovalViewMobile(),
      desktop: (context) => RequestApprovalViewDesktop(),
    );
  }
}
