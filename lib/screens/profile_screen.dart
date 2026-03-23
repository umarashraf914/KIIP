import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final settings = context.watch<SettingsService>();
    final user = auth.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: auth.isSignedIn
                  ? Row(
                      children: [
                        UserAvatar(radius: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user!.name.isNotEmpty
                                    ? user.name
                                    : 'User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface.withAlpha(150),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => context.push('/profile/edit'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Icon(
                          Icons.account_circle,
                          size: 64,
                          color: colorScheme.onSurface.withAlpha(80),
                        ),
                        const SizedBox(height: 12),
                        const Text('Not signed in'),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Sign In'),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Preferences section
          _SectionHeader(title: 'Preferences'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode'),
                  value: settings.settings.isDarkMode,
                  onChanged: (v) => settings.setDarkMode(v),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.speed_outlined),
                  title: const Text('TTS Speed'),
                  subtitle: Text('${settings.ttsSpeed.toStringAsFixed(1)}x'),
                  onTap: () => _showTtsSpeedDialog(context, settings),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  value: settings.settings.notificationsEnabled,
                  onChanged: (v) => settings.setNotifications(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // About section
          _SectionHeader(title: 'About'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('App Version'),
                  trailing: Text(
                    '1.0.0',
                    style: TextStyle(
                      color: colorScheme.onSurface.withAlpha(120),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sign out
          if (auth.isSignedIn) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmSignOut(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showTtsSpeedDialog(BuildContext context, SettingsService settings) {
    var speed = settings.ttsSpeed;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'TTS Speed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('${speed.toStringAsFixed(1)}x',
                  style: const TextStyle(fontSize: 24)),
              Slider(
                value: speed,
                min: 0.1,
                max: 1.0,
                divisions: 9,
                label: '${speed.toStringAsFixed(1)}x',
                onChanged: (v) {
                  setSheetState(() => speed = v);
                },
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  settings.setTtsSpeed(speed);
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthService>().signOut();
              context.go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
        letterSpacing: 0.5,
      ),
    );
  }
}
