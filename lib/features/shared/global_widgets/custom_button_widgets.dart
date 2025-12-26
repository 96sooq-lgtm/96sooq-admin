import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool isLoadingVisible;
  final VoidCallback onPressed;
  final bool isLoading;
  final TextStyle? textStyle;
  final double fontSize;
  final Color color;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isLoadingVisible = true,
    this.textStyle,
    this.color = AppColors.primaryColor,
    this.fontSize = 16, // Default font size
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonWidth = constraints.maxWidth;
        double buttonHeight = 56;

        return GestureDetector(
          onTap: isLoading ? null : onPressed,
          child: Container(
            width: buttonWidth,
            height: buttonHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: color,
            ),
            child: Center(
              child: (isLoading && isLoadingVisible)
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      text,
                      style:
                          textStyle ??
                          AppThemes.f16w600.copyWith(
                            color: Colors.white,
                            fontSize: fontSize, // Use fontSize here
                          ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ),
        );
      },
    );
  }
}
