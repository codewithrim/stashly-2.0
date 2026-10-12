import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/item.dart';
import '../auth/biometric_provider.dart';
import '../providers.dart';
import 'filter_provider.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bioState = ref.watch(biometricLockProvider);
    if (bioState.isBiometricEnabled && !bioState.isUnlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/biometric-lock');
      });
    }

    final filterState = ref.watch(filterProvider);
    final itemsAsync = ref.watch(filteredItemsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bookmark_rounded, color: Color(0xFF6366F1), size: 28),
            SizedBox(width: 8),
            Text('Stashly', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              filterState.showArchived ? Icons.inbox_rounded : Icons.archive_outlined,
              color: filterState.showArchived ? const Color(0xFF6366F1) : null,
            ),
            tooltip: filterState.showArchived ? 'View Active Inbox' : 'View Archive',
            onPressed: () {
              ref.read(filterProvider.notifier).toggleArchived(!filterState.showArchived);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(115),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search title, content, tags, or URLs...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: filterState.query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => ref.read(filterProvider.notifier).setQuery(''),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                  onChanged: (val) => ref.read(filterProvider.notifier).setQuery(val),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: filterState.typeFilter == null,
                      onSelected: (_) => ref.read(filterProvider.notifier).setTypeFilter(null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.description_outlined, size: 16),
                      label: const Text('Notes'),
                      selected: filterState.typeFilter == ItemType.note,
                      onSelected: (_) => ref.read(filterProvider.notifier).setTypeFilter(ItemType.note),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.link_rounded, size: 16),
                      label: const Text('Links'),
                      selected: filterState.typeFilter == ItemType.link,
                      onSelected: (_) => ref.read(filterProvider.notifier).setTypeFilter(ItemType.link),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      avatar: const Icon(Icons.image_outlined, size: 16),
                      label: const Text('Images'),
                      selected: filterState.typeFilter == ItemType.image,
                      onSelected: (_) => ref.read(filterProvider.notifier).setTypeFilter(ItemType.image),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Error loading items: $err', style: TextStyle(color: theme.colorScheme.error)),
        ),
        data: (items) {
          if (items.isEmpty) {
            return _buildEmptyState(context, filterState);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildItemCard(context, ref, item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/editor/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Item'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, WidgetRef ref, SavedItem item) {
    final theme = Theme.of(context);
    final repo = ref.read(itemRepositoryProvider);

    IconData typeIcon;
    Color typeColor;
    switch (item.type) {
      case ItemType.note:
        typeIcon = Icons.description_outlined;
        typeColor = const Color(0xFF3B82F6);
        break;
      case ItemType.link:
        typeIcon = Icons.link_rounded;
        typeColor = const Color(0xFF10B981);
        break;
      case ItemType.image:
        typeIcon = Icons.image_outlined;
        typeColor = const Color(0xFF8B5CF6);
        break;
    }

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: item.archived ? Colors.blue : Colors.amber.shade700,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(item.archived ? Icons.unarchive : Icons.archive, color: Colors.white),
            const SizedBox(width: 8),
            Text(item.archived ? 'Restore' : 'Archive', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.delete_outline, color: Colors.white),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete confirmation
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete Item?'),
              content: Text('Are you sure you want to delete "${item.title}"?'),
              actions: [
                TextButton(onPressed: () => ctx.pop(false), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () => ctx.pop(true),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ) ?? false;
        } else {
          // Archive or restore toggle
          await repo.archiveItem(item.id, !item.archived);
          return false;
        }
      },
      onDismissed: (_) async {
        await repo.deleteItem(item.id);
      },
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/item/${item.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(typeIcon, color: typeColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title.isEmpty ? 'Untitled' : item.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.url != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              Uri.tryParse(item.url!)?.host ?? item.url!,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (item.remindAt != null) ...[
                      const Icon(Icons.notifications_active, size: 18, color: Colors.amber),
                      const SizedBox(width: 6),
                    ],
                    if (item.attachmentPath != null)
                      const Icon(Icons.attach_file, size: 18, color: Colors.blueGrey),
                  ],
                ),
                if (item.content != null && item.content!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    item.content!.trim(),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.75),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: item.tags.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#$t',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, FilterState filterState) {
    final isSearching = filterState.query.isNotEmpty || filterState.typeFilter != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : (filterState.showArchived ? Icons.archive_outlined : Icons.bookmark_border_rounded),
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'No matching items found'
                  : (filterState.showArchived ? 'No archived items' : 'Your inbox is empty'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Try tweaking your search keywords or clear active filters.'
                  : (filterState.showArchived
                      ? 'Items you archive will appear here.'
                      : 'Tap the button below to save your first note, link, or snippet.'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
