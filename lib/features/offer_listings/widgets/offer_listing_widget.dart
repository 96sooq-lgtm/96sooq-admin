import 'package:_96sooq_admin/constants/themes.dart' show AppThemes;
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:flutter/material.dart';

class OfferListingWidget extends StatelessWidget {
  const OfferListingWidget({
    super.key,
    required this.offerTitle,
    required this.seller,
    required this.dateOfSubmission,
    required this.isReviewed,
  });
  final String offerTitle;
  final String seller;
  final bool isReviewed;
  final String dateOfSubmission;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          SizedBox(width: 40),
          Expanded(
            flex: 2,
            child: DynamicText(
              offerTitle,
              style: AppThemes.f20w300,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: DynamicText(seller, style: AppThemes.f20w300)),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: DynamicText(dateOfSubmission, style: AppThemes.f20w300),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                !isReviewed
                    ? IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.check_circle,
                          color: Color(0xFF008258),
                        ),
                      )
                    : SizedBox(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.close, color: Color(0xFFF93939)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
