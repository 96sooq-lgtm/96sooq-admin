import 'package:_96sooq_admin/constants/strings.dart';
import 'package:_96sooq_admin/constants/themes.dart';
import 'package:flutter/material.dart';

class AdBannerListingWidget extends StatelessWidget {
  const AdBannerListingWidget({
    super.key,
    required this.name,
    required this.imgPath,
    required this.duration,
  });
  final String name;
  final String imgPath;
  final String duration;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          SizedBox(width: 40),
          Expanded(
            flex: 2,
            child: Center(child: BannerWidget(imgPath: imgPath)),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Center(child: Text(name, style: AppThemes.f20w300,maxLines: 2,)),
          ),
          Expanded(
            flex: 2,
            child: Center(child: Text(duration, style: AppThemes.f20w300)),
          ),
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

class BannerWidget extends StatelessWidget {
  final String imgPath;
  const BannerWidget({super.key, required this.imgPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Color(0xFFE1E1E1)),
      ),
      child: imgPath.isEmpty
          ? Center(child: Icon(Icons.image_outlined))
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(imgPath),
            ),
    );
  }
}
