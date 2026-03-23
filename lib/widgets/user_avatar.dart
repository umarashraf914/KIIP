import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class UserAvatar extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({super.key, this.radius = 18, this.onTap});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    Widget avatar;
    if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(user.photoUrl!),
        backgroundColor: colorScheme.primaryContainer,
      );
    } else {
      final initials = _getInitials(user?.name ?? '');
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          initials,
          style: TextStyle(
            fontSize: radius * 0.8,
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
