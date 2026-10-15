import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../auth/auth_controller.dart';
import '../auth/biometric_provider.dart';
import '../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final colors = context.stashlyColors;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Account',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: colors.accentPrimary)),
          ),
          Builder(
            builder: (context) {
              final badgeColors = AppTheme.syncBadgeColors(
                user != null,
                context.stashlyColors,
              );
              return ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(user?.email ?? 'Local User'),
                subtitle: Text('UID: ${user?.id ?? "local"}',
                    style: const TextStyle(fontSize: 12)),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    user != null ? 'Synced' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: badgeColors.foreground,
                    ),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.orange),
            title: const Text('Sign Out'),
            subtitle: const Text(
                'Wipes local device cache to prevent data leaks across accounts'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out?'),
                  content: const Text(
                      'Signing out will clear local cache on this device.'),
                  actions: [
                    TextButton(
                        onPressed: () => ctx.pop(false),
                        child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () => ctx.pop(true),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/auth');
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            title: Text('Security & Privacy',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: colors.accentPrimary)),
          ),
          SwitchListTile(
            secondary: Icon(Icons.fingerprint, color: colors.accentPrimary),
            title: const Text('Biometric App Lock'),
            subtitle: const Text(
                'Require fingerprint or face ID when opening Stashly'),
            value: ref.watch(biometricLockProvider).isBiometricEnabled,
            onChanged: (val) {
              ref.read(biometricLockProvider.notifier).setBiometricEnabled(val);
            },
          ),
          const Divider(),
          ListTile(
            title: Text('Data Ownership (Mission E)',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: colors.accentPrimary)),
          ),
          ListTile(
            leading:
                Icon(Icons.file_download_outlined, color: colors.accentPrimary),
            title: const Text('Export My Data'),
            subtitle: const Text(
                'Export all items, tags, timestamps & metadata as formatted JSON'),
            onTap: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Preparing your JSON export...')),
                );
                await ref.read(dataOwnershipServiceProvider).exportAndShare();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: const Text('Delete Account & All Data',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            subtitle: const Text(
                'Permanently deletes account, database rows, storage files, and local cache'),
            onTap: () async {
              final confirmationTextController = TextEditingController();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Account & All Data?'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'This action is irreversible. The following will be permanently removed:\n'
                        '• Your account credentials\n'
                        '• All saved notes, links, and snippets\n'
                        '• All uploaded files from attachments storage\n'
                        '• All public share links (they will immediately stop working)\n'
                        '• Local device database and cache\n\n'
                        'Type "DELETE" below to confirm:',
                        style: TextStyle(fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: confirmationTextController,
                        decoration: const InputDecoration(
                          hintText: 'Type DELETE',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => ctx.pop(false),
                        child: const Text('Cancel')),
                    FilledButton(
                      style:
                          FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        if (confirmationTextController.text.trim() ==
                            'DELETE') {
                          ctx.pop(true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please type DELETE to confirm.')),
                          );
                        }
                      },
                      child: const Text('Delete Everything'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                try {
                  await ref.read(dataOwnershipServiceProvider).deleteAccount();
                  if (context.mounted) {
                    context.go('/auth');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Delete failed: $e')),
                    );
                  }
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            title: Text('Local Device Cache',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: colors.accentPrimary)),
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined,
                color: Colors.orange),
            title: const Text('Wipe Local Cache'),
            subtitle: const Text(
                'Clear SQLite cache from this device only (remote data stays safe)'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Local Database?'),
                  content: const Text(
                      'This will delete all local SQLite cached records and drafts.'),
                  actions: [
                    TextButton(
                        onPressed: () => ctx.pop(false),
                        child: const Text('Cancel')),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange),
                      onPressed: () => ctx.pop(true),
                      child: const Text('Wipe Local'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref.read(itemRepositoryProvider).wipeLocalData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Local data cleared successfully.')),
                  );
                  context.go('/');
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            title: Text('About',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: colors.accentPrimary)),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Stashly 2.0'),
            subtitle: Text(
                'Full-scope implementation of every stage & advanced mission in stashly.md'),
          ),
        ],
      ),
    );
  }
}
