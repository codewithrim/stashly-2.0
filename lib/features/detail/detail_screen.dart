import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/item.dart';
import '../providers.dart';

class DetailScreen extends ConsumerWidget {
  final String itemId;

  const DetailScreen({super.key, required this.itemId});

  Future<void> _openUrl(BuildContext context, String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link in browser.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemDetailProvider(itemId));
    final repo = ref.read(itemRepositoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Detail'),
        actions: [
          itemAsync.maybeWhen(
            data: (item) {
              if (item == null) return const SizedBox.shrink();
              return Row(
                children: [
                  IconButton(
                    icon: Icon(item.archived ? Icons.unarchive : Icons.archive_outlined),
                    tooltip: item.archived ? 'Restore' : 'Archive',
                    onPressed: () async {
                      await repo.archiveItem(item.id, !item.archived);
                      ref.invalidate(itemDetailProvider(itemId));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit',
                    onPressed: () => context.push('/editor/${item.id}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    tooltip: 'Delete',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Item?'),
                          content: const Text('Are you sure you want to delete this item?'),
                          actions: [
                            TextButton(onPressed: () => ctx.pop(false), child: const Text('Cancel')),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => ctx.pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await repo.deleteItem(item.id);
                        if (context.mounted) context.pop();
                      }
                    },
                  ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: itemAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (item) {
          if (item == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Item not found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('This item may have been deleted or is unavailable.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Return to Inbox'),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Title
              Text(
                item.title.isEmpty ? 'Untitled' : item.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Tags
              if (item.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: item.tags.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('#$t', style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // URL Card
              if (item.url != null && item.url!.isNotEmpty) ...[
                Card(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  child: ListTile(
                    leading: const Icon(Icons.link, color: Color(0xFF6366F1)),
                    title: Text(
                      item.url!,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF6366F1)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          tooltip: 'Copy URL',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: item.url!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('URL copied to clipboard')),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_browser, size: 20),
                          tooltip: 'Open in Browser',
                          onPressed: () => _openUrl(context, item.url!),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Content Body
              if (item.content != null && item.content!.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      item.content!,
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Metadata Footer
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created: ${DateFormat.yMMMd().add_jm().format(item.createdAt.toLocal())}',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  Text(
                    'Updated: ${DateFormat.yMMMd().add_jm().format(item.updatedAt.toLocal())}',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
