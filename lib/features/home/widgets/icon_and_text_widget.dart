import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

class IconAndTextWidget extends StatelessWidget {
  const IconAndTextWidget({
    super.key,
    required this.svgPath,
    required this.title,
    this.count,
    this.isLoading = false,
    this.onTap,
  });

  final String svgPath;
  final String title;
  final int? count;
  final bool isLoading;
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DynamicText(
                    title,
                    textAlign: TextAlign.left,
                    // overflow: TextOverflow.ellipsis,
                    style: AppThemes.f20w500.copyWith(color: Color(0xFF8A8A8A)),
                  ),
                  if (isLoading)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 80,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    )
                  else
                    DynamicText(
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
