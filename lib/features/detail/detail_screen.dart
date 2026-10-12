import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
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
    final shareLinkAsync = ref.watch(itemShareLinkProvider(itemId));
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
                        if (item.attachmentPath != null) {
                          await ref.read(attachmentServiceProvider).deleteAttachment(item.attachmentPath!);
                        }
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
              Text(
                item.title.isEmpty ? 'Untitled' : item.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

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

              // Mission B: Public Sharing Link Card
              shareLinkAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
                data: (shareLink) {
                  final hasActiveLink = shareLink != null && shareLink.isActive;
                  final publicUrl = hasActiveLink
                      ? 'https://codewithrim.github.io/stashly-2.0/?t=${shareLink.token}'
                      : null;

                  return Card(
                    color: hasActiveLink ? const Color(0xFF6366F1).withOpacity(0.08) : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                hasActiveLink ? Icons.public : Icons.public_off,
                                color: hasActiveLink ? const Color(0xFF6366F1) : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                hasActiveLink ? 'Public Read-Only Link (Active)' : 'Public Link Sharing',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            hasActiveLink
                                ? 'Anyone with this link can view this note/link. Attachments are not shared.'
                                : 'Generate an unguessable read-only link to share this item publicly.',
                            style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                          ),
                          const SizedBox(height: 12),
                          if (hasActiveLink) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: theme.colorScheme.outlineVariant),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      publicUrl!,
                                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 18),
                                    tooltip: 'Copy Link',
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: publicUrl));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Public link copied!')),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share, size: 18),
                                    tooltip: 'Share',
                                    onPressed: () {
                                      Share.share(publicUrl, subject: item.title);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () async {
                                await ref
                                    .read(shareLinkServiceProvider)
                                    .revokeShareLink(shareLink.token);
                                ref.invalidate(itemShareLinkProvider(itemId));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Public link revoked successfully.')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.link_off, color: Colors.red),
                              label: const Text('Revoke Link', style: TextStyle(color: Colors.red)),
                            ),
                          ] else ...[
                            FilledButton.icon(
                              onPressed: () async {
                                await ref
                                    .read(shareLinkServiceProvider)
                                    .createShareLink(item.id);
                                ref.invalidate(itemShareLinkProvider(itemId));
                              },
                              icon: const Icon(Icons.add_link),
                              label: const Text('Create Public Link'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Attachment Preview Card
              if (item.attachmentPath != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          item.attachmentMime == 'application/pdf'
                              ? Icons.picture_as_pdf
                              : Icons.image,
                          color: const Color(0xFF6366F1),
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.attachmentName ?? 'Attachment',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.attachmentMime ?? '',
                                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.open_in_new),
                          tooltip: 'Open Attachment via Signed URL',
                          onPressed: () async {
                            final signedUrl = await ref
                                .read(attachmentServiceProvider)
                                .getSignedUrl(item.attachmentPath!);
                            if (context.mounted) {
                              _openUrl(context, signedUrl);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

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
