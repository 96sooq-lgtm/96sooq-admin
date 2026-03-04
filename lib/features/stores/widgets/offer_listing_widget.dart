import 'package:_96sooq_admin/constants/colors.dart';
import 'package:_96sooq_admin/constants/themes.dart' show AppThemes;
import 'package:_96sooq_admin/core/bloc/language/widgets/dynamic_text.dart';
import 'package:_96sooq_admin/features/stores/model/store_model.dart';
import 'package:_96sooq_admin/features/stores/bloc/store_bloc.dart';
import 'package:_96sooq_admin/features/stores/bloc/store_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OfferListingWidget extends StatelessWidget {
  const OfferListingWidget({super.key, required this.store});

  final StoreModel store;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            flex: 1,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFEFEFEF),
              child: ClipOval(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: store.logo.isNotEmpty
                      ? Image.network(
                          store.logo,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('❌ Store logo failed to load');
                            debugPrint('URL: ${store.logo}');
                            debugPrint('Error: $error');
                            debugPrint('StackTrace: $stackTrace');
                            return const Center(
                              child: Icon(
                                Icons.store_outlined,
                                size: 24,
                                color: Color(0xFF9CA3AF),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.store_outlined,
                            size: 24,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: DynamicText(
              store.name,
              style: AppThemes.f20w300,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: _StatusChip(isActive: !store.isLocked)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (store.isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                else
                  PopupMenuButton<String>(
                    color: Colors.white,
                    onSelected: (value) {
                      final bool isLocking = value == 'inactive';
                      if (store.isLocked != isLocking) {
                        context.read<StoreBloc>().add(
                          ToggleStoreStatus(store: store, isLocking: isLocking),
                        );
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'active',
                        child: Text('Active'),
                      ),
                      PopupMenuItem<String>(
                        value: 'inactive',
                        child: Text('Inactive'),
                      ),
                    ],
                    icon: const Icon(Icons.edit, color: AppColors.primaryColor),
                  ),
              ],
            ),
          ),
        ],
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
        color: isActive ? const Color(0xFFDBFCE7) : const Color(0xFFFFE2E2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: DynamicText(
          isActive ? 'Active' : 'Inactive',
          style: AppThemes.f20w400.copyWith(
            color: isActive ? const Color(0xFF1E8E4E) : const Color(0xFFF93939),
          ),
        ),
      ),
    );
  }
}
