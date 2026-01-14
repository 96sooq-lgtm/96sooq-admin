import 'package:_96sooq_admin/constants/themes.dart';
import 'package:flutter/material.dart';

class UserListingWidget extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String status;
  const UserListingWidget({
    super.key,
    required this.status,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Active';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          SizedBox(width: 40),
          Expanded(
            flex: 2,
            child: Text(userName, style: AppThemes.f20w300, maxLines: 2),
          ),
          Expanded(
            flex: 2,
            child: Text(userEmail, style: AppThemes.f20w300, maxLines: 2),
          ),
          Expanded(flex: 1, child: _StatusChip(isActive: isActive)),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              children: [
                isActive
                    ? IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.check_circle,
                          color: Color(0xFF008258),
                        ),
                      )
                    : IconButton(
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
        child: Text(
          isActive ? 'Active' : 'Block',
          style: AppThemes.f20w400.copyWith(
            color: isActive ? const Color(0xFF1E8E4E) : Color(0xFFF93939),
          ),
        ),
      ),
    );
  }
}
