import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_navigation_cubit.dart';
import 'package:flutter_svg/svg.dart';

class AdminSidebarItemWidget extends StatelessWidget {
  final int index;
  final Widget title;
  final String svgAssetSelected;
  final String svgAssetNotSelected;
  final int? notificationCount;

  const AdminSidebarItemWidget({
    super.key,
    required this.index,
    required this.title,
    required this.svgAssetSelected,
    required this.svgAssetNotSelected,
    this.notificationCount,
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
                Expanded(child: title),
                if (notificationCount != null && notificationCount! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      notificationCount.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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
