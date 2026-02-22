import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:flutter/material.dart';

class AdBannerListingWidget extends StatelessWidget {
  const AdBannerListingWidget({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.linkUrl,
    required this.duration,
    required this.onPreviewTap,
    required this.onLinkTap,
    required this.onEdit,
    required this.onDelete,
    this.isVertical = false,
  });
  final String name;
  final String imageUrl;
  final String linkUrl;
  final String duration;
  final VoidCallback onPreviewTap;
  final VoidCallback onLinkTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            flex: 2,
            child: Center(
              child: BannerWidget(
                imageUrl: imageUrl,
                onTap: onPreviewTap,
                isVertical: isVertical,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Center(
              child: DynamicText(name, style: AppThemes.f20w300, maxLines: 2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: onLinkTap,
              child: DynamicText(
                linkUrl,
                style: AppThemes.f16w400.copyWith(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                maxLines: 2,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: DynamicText(duration, style: AppThemes.f20w300),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: onDelete,
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
  final String imageUrl;
  final VoidCallback onTap;
  final bool isVertical;

  const BannerWidget({
    super.key,
    required this.imageUrl,
    required this.onTap,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;
    final firstImageUrl = imageUrl.split(',').first.trim();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: isVertical ? 160 : 92,
        width: isVertical ? 106 : double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE1E1E1)),
        ),
        child: !hasImage
            ? const Center(child: Icon(Icons.image_outlined))
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  firstImageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Color(0xFF9CA3AF),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
