import 'package:_96sooq_admin/constants/strings.dart';
import 'package:_96sooq_admin/features/root/widgets/admin_sidebar_item_widget.dart';
import 'package:flutter/material.dart';

class AdminSidebarWidget extends StatelessWidget {
  const AdminSidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.only(left: 28,right: 28,bottom: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 30),
          AdminSidebarItemWidget(
            index: 0,
            title: 'Dashboard',
            svgAssetSelected: AssetPath.homeSelectedIc,
            svgAssetNotSelected: AssetPath.homeUnSelectedIc,
          ),
          AdminSidebarItemWidget(
            index: 1,
            title: 'Category',
            svgAssetSelected: AssetPath.categorySelectedIc,
            svgAssetNotSelected: AssetPath.categoryUnSelectedIc,
          ),
          AdminSidebarItemWidget(
            index: 2,
            title: 'Sub Category',
            svgAssetSelected: AssetPath.subcategorySelectedIc,
            svgAssetNotSelected: AssetPath.subcategoryUnSelectedIc,
          ),
        ],
      ),
    );
  }
}
