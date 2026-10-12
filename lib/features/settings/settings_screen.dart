import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Account', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Current Mode'),
            subtitle: const Text('Local Mode (Phase 1 SQLite)'),
            trailing: Chip(
              label: const Text('Offline First', style: TextStyle(fontSize: 12)),
              backgroundColor: Colors.green.shade100,
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text('Data Ownership', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export My Data'),
            subtitle: const Text('Download all items and tags as a JSON file'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting data as JSON (Mission E)...')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: const Text('Wipe Local Data', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Clear all cached items and drafts from this device'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear Local Database?'),
                  content: const Text('This will delete all local items and cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => ctx.pop(false), child: const Text('Cancel')),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => ctx.pop(true),
                      child: const Text('Wipe All'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref.read(itemRepositoryProvider).wipeLocalData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Local data cleared successfully.')),
                  );
                  context.go('/');
                }
              }
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('About', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Stashly 2.0'),
            subtitle: Text('Built with Flutter & Drift SQLite'),
          ),
        ],
      ),
    );
  }
}
