import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:flutter/material.dart';

class CategoryListWidget extends StatelessWidget {
  final String imageUrl;
  final String name;
  final Widget? nameWidget;
  final bool isActive;
  final String statusLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const CategoryListWidget({
    super.key,
    required this.imageUrl,
    required this.name,
    this.nameWidget,
    required this.isActive,
    required this.statusLabel,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          SizedBox(width: 40),
          Expanded(flex: 1, child: _CategoryImage(imageUrl: imageUrl)),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child:
                nameWidget ??
                DynamicText(name, style: AppThemes.f20w300, maxLines: 2),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: _StatusChip(isActive: isActive, label: statusLabel),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
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

class _CategoryImage extends StatelessWidget {
  final String imageUrl;

  const _CategoryImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = imageUrl;
    final hasImage = resolvedUrl.isNotEmpty;
    return InkWell(
      onTap: hasImage
          ? () {
              showDialog(
                context: context,
                builder: (_) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(24),
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Image.network(
                              resolvedUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('❌ Image failed to load');
                                debugPrint('URL: $resolvedUrl');
                                debugPrint('Error: $error');
                                debugPrint('StackTrace: $stackTrace');

                                return const SizedBox(
                                  width: 320,
                                  height: 240,
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 32,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          : null,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFFEFEFEF),
        child: ClipOval(
          child: SizedBox(
            width: 36,
            height: 36,
            child: hasImage
                ? Image.network(
                    resolvedUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('❌ Thumbnail image failed to load');
                      debugPrint('URL: $resolvedUrl');
                      debugPrint('Error: $error');
                      debugPrint('StackTrace: $stackTrace');

                      return const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 18,
                          color: Color(0xFF9CA3AF),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 18,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;
  final String label;

  const _StatusChip({required this.isActive, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDBFCE7) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: DynamicText(
          label,
          style: AppThemes.f20w400.copyWith(
            color: isActive ? const Color(0xFF1E8E4E) : Color(0xFF2A2F3B),
          ),
        ),
      ),
    );
  }
}
