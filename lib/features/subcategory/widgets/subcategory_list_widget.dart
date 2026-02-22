import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:flutter/material.dart';

class SubcategoryListWidget extends StatefulWidget {
  final String imageUrl;
  final String categoryName;
  final String subCategoryName;
  final String status;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  const SubcategoryListWidget({
    super.key,
    required this.imageUrl,
    required this.status,
    required this.categoryName,
    required this.subCategoryName,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  State<SubcategoryListWidget> createState() => _SubcategoryListWidgetState();
}

class _SubcategoryListWidgetState extends State<SubcategoryListWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.status == 'Active';

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: _isHovered ? const Color(0xFFF9FAFB) : Colors.white,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  flex: 1,
                  child: _SubcategoryImage(imageUrl: widget.imageUrl),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DynamicText(
                    widget.subCategoryName,
                    style: AppThemes.f20w300,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: DynamicText(
                    widget.categoryName,
                    style: AppThemes.f20w300,
                  ),
                ),
                Expanded(flex: 1, child: _StatusChip(isActive: isActive)),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .center,
                    children: [
                      IconButton(
                        onPressed: widget.onEdit,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: widget.onDelete,
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
          ),
        ),
      ),
    );
  }
}

class _SubcategoryImage extends StatelessWidget {
  final String imageUrl;

  const _SubcategoryImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = imageUrl.trim();
    final hasImage = resolvedUrl.isNotEmpty;
    return CircleAvatar(
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
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;

  const _StatusChip({required this.isActive});

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
          isActive ? 'Active' : 'Inactive',
          style: AppThemes.f20w400.copyWith(
            color: isActive ? const Color(0xFF1E8E4E) : Color(0xFF2A2F3B),
          ),
        ),
      ),
    );
  }
}
