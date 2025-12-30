import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_navigation_cubit.dart';
import 'package:flutter_svg/svg.dart';

class AdminSidebarItemWidget extends StatelessWidget {
  final int index;
  final String title;
  final String svgAssetSelected;
  final String svgAssetNotSelected;

  const AdminSidebarItemWidget({
    super.key,
    required this.index,
    required this.title,
    required this.svgAssetSelected,
    required this.svgAssetNotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminNavigationCubit, int>(
      builder: (context, selectedIndex) {
        final isSelected = selectedIndex == index;

        return InkWell(
          onTap: () {
            context.read<AdminNavigationCubit>().changePage(index);
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  isSelected ? svgAssetSelected : svgAssetNotSelected,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: AppThemes.f20w500.copyWith(
                    color: isSelected
                        ? AppColors.whiteTextColor
                        : AppColors.blackTextColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
