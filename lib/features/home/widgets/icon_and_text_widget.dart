import 'package:_96sooq_admin/constants/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class IconAndTextWidget extends StatelessWidget {
  const IconAndTextWidget({
    super.key,
    required this.svgPath,
    required this.title,
    this.count,
    this.onTap,
  });

  final String svgPath;
  final String title;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE1E1E1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: SvgPicture.asset(svgPath),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .start,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.left,
                    // overflow: TextOverflow.ellipsis,
                    style: AppThemes.f20w500.copyWith(color: Color(0xFF8A8A8A)),
                  ),
                  Text(
                    "$count",
                    textAlign: TextAlign.center,
                    style: AppThemes.f24w500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
