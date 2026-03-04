import 'package:_96sooq_admin/constants/themes.dart';
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/request_approval/model/listing_model.dart';
import 'package:flutter/material.dart';

class ListingDetailsWidget extends StatefulWidget {
  final ListingModel listing;
  final VoidCallback? onClose;

  const ListingDetailsWidget({Key? key, required this.listing, this.onClose})
    : super(key: key);

  @override
  State<ListingDetailsWidget> createState() => _ListingDetailsWidgetState();
}

class _ListingDetailsWidgetState extends State<ListingDetailsWidget> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStoreHeader(),
                      const SizedBox(height: 12),
                      _buildTitleAndPrice(),
                      const SizedBox(height: 12),
                      _buildLocation(),
                      const SizedBox(height: 16),
                      _buildDescription(),
                      const SizedBox(height: 16),
                      _buildChips(),
                      const SizedBox(height: 24),
                      if (widget.listing.attributesValues != null &&
                          widget.listing.attributesValues!.isNotEmpty)
                        _buildAttributes(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.onClose != null)
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black54),
                onPressed: widget.onClose,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.listing.images.isNotEmpty
        ? widget.listing.images
        : [
            // Dummy placeholder if no array provided
            'https://via.placeholder.com/400x300?text=No+Image',
          ];

    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: images.asMap().entries.map((entry) {
                return Container(
                  width: _currentImageIndex == entry.key ? 16.0 : 6.0,
                  height: 6.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _currentImageIndex == entry.key
                        ? Colors.black87
                        : Colors.black38,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreHeader() {
    final isIndividual =
        widget.listing.sellerType.toLowerCase() == 'individual';
    final String? imageUrl = isIndividual
        ? widget.listing.userProfilePicture
        : widget.listing.storeLogo;
    final String displayName = isIndividual
        ? (widget.listing.userName ?? 'Unknown Seller')
        : (widget.listing.storeName ?? 'Unknown Store');
    final IconData fallbackIcon = isIndividual ? Icons.person : Icons.store;

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
          child: imageUrl == null
              ? Icon(fallbackIcon, size: 16, color: Colors.grey)
              : null,
        ),
        const SizedBox(width: 8),
        Flexible(child: DynamicText(displayName, style: AppThemes.f16w600)),
      ],
    );
  }

  Widget _buildTitleAndPrice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DynamicText(
            widget.listing.title,
            style: AppThemes.f20w600.copyWith(color: const Color(0xFF1E293B)),
          ),
        ),
        const SizedBox(width: 16),
        DynamicText(
          '${widget.listing.price.toInt()} ${widget.listing.currency}',
          style: AppThemes.f18w600.copyWith(color: const Color(0xFF1E293B)),
        ),
      ],
    );
  }

  Widget _buildLocation() {
    final governorate = widget.listing.governorateNameEn;
    final wilayat = widget.listing.wilayatNameEn;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (governorate != null && governorate.isNotEmpty)
          _buildLocationPill(
            icon: Icons.map_outlined,
            label: 'Governorate',
            value: governorate,
          ),
        if (wilayat != null && wilayat.isNotEmpty)
          _buildLocationPill(
            icon: Icons.location_on_outlined,
            label: 'Wilayat',
            value: wilayat,
          ),
        if ((governorate == null || governorate.isEmpty) &&
            (wilayat == null || wilayat.isEmpty))
          _buildLocationPill(
            icon: Icons.location_off_outlined,
            label: '',
            value: 'No location provided',
          ),
      ],
    );
  }

  Widget _buildLocationPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          if (label.isNotEmpty) ...[
            DynamicText(
              '$label: ',
              style: AppThemes.f14w600.copyWith(color: const Color(0xFF64748B)),
            ),
          ],
          Flexible(
            child: DynamicText(
              value,
              style: AppThemes.f14w400.copyWith(color: const Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return DynamicText(
      widget.listing.description,
      style: AppThemes.f14w400.copyWith(
        color: const Color(0xFF64748B),
        height: 1.5,
      ),
    );
  }

  Widget _buildChips() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (widget.listing.parentCategoryNameEn != null &&
            widget.listing.parentCategoryNameEn!.isNotEmpty)
          _buildInfoChip(
            icon: Icons.category_outlined,
            label: 'Category: ${widget.listing.parentCategoryNameEn!}',
            bgColor: const Color(0xFFF3F4F6),
            textColor: const Color(0xFF4B5563),
          ),
        if (widget.listing.categoryNameEn != null &&
            widget.listing.categoryNameEn!.isNotEmpty)
          _buildInfoChip(
            icon: Icons.subdirectory_arrow_right,
            label: 'Subcategory: ${widget.listing.categoryNameEn!}',
            bgColor: const Color(0xFFF3F4F6),
            textColor: const Color(0xFF4B5563),
          ),
        _buildInfoChip(
          icon: Icons.verified_outlined,
          label: 'Condition: ${widget.listing.condition.toUpperCase()}',
          bgColor: const Color(0xFFEFF6FF),
          textColor: const Color(0xFF3B82F6),
        ),
        _buildInfoChip(
          icon: Icons.storefront_outlined,
          label: 'Seller Type: ${widget.listing.sellerType.toUpperCase()}',
          bgColor: const Color(0xFFF0FDF4),
          textColor: const Color(0xFF22C55E),
        ),
        if (widget.listing.sellerPhoneNumber != null &&
            widget.listing.sellerPhoneNumber!.isNotEmpty)
          _buildInfoChip(
            icon: Icons.phone_outlined,
            label: widget.listing.sellerPhoneNumber!,
            bgColor: const Color(0xFFFFF7ED),
            textColor: const Color(0xFFEA580C),
          ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          DynamicText(
            label,
            style: AppThemes.f12w600.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.listing.attributesValues!.entries.map((entry) {
          final dynValue = entry.value;
          if (dynValue is Map<String, dynamic>) {
            final label =
                dynValue['label_en'] ?? dynValue['label_ar'] ?? entry.key;
            final val = dynValue['value']?.toString() ?? 'N/A';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DynamicText(
                    label.toString().toUpperCase(),
                    style: AppThemes.f12w600.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  DynamicText(
                    val,
                    style: AppThemes.f14w600.copyWith(
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }).toList(),
      ),
    );
  }
}
