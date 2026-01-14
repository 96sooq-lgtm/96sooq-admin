import 'package:_96sooq_admin/constants/themes.dart';
import 'package:flutter/material.dart';

class PromotionSlabListingWidget extends StatelessWidget {
  const PromotionSlabListingWidget({
    super.key,
    required this.name,
    required this.price,
    required this.duration,
  });
  final String name;
  final String price;
  final String duration;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          SizedBox(width: 40),
          Expanded(flex: 2, child: Text(name, style: AppThemes.f20w300)),
          Expanded(flex: 2, child: Center(child: Text(price, style: AppThemes.f20w300))),
          Expanded(flex: 2, child: Center(child: Text(duration, style: AppThemes.f20w300))),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFF93939),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
