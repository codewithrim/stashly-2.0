import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/models/item.dart';
import '../../data/repositories/synced_item_repository.dart';
import '../auth/biometric_provider.dart';
import '../providers.dart';
import 'filter_provider.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  late final TextEditingController _searchController;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    final initialQuery = ref.read(filterProvider).query;
    _searchController = TextEditingController(text: initialQuery);
    _isSearchExpanded = initialQuery.isNotEmpty;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    ref.read(filterProvider.notifier).setQuery(val);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(filterProvider.notifier).setQuery('');
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _clearSearch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bioState = ref.watch(biometricLockProvider);
    if (bioState.isBiometricEnabled && !bioState.isUnlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/biometric-lock');
      });
    }

    final filterState = ref.watch(filterProvider);
    final itemsAsync = ref.watch(filteredItemsProvider);
    final colors = context.stashlyColors;

    // Listen to query changes from outside (e.g. clear filters)
    ref.listen(filterProvider.select((s) => s.query), (_, next) {
      if (next != _searchController.text) {
        _searchController.text = next;
        if (next.isNotEmpty && !_isSearchExpanded) {
          setState(() => _isSearchExpanded = true);
        }
      }
    });

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.surfaceBorder, width: 0.8),
              ),
              child: Icon(
                filterState.showArchived
                    ? Icons.archive_rounded
                    : Icons.bookmark_rounded,
                color: colors.accentPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  filterState.showArchived ? 'Archive' : 'Stashly',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: colors.textPrimary,
                  ),
                ),
                itemsAsync.maybeWhen(
                  data: (items) => Text(
                    '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: colors.textTertiary,
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchExpanded
                  ? Icons.search_off_rounded
                  : Icons.search_rounded,
              color: _isSearchExpanded || filterState.query.isNotEmpty
                  ? colors.accentPrimary
                  : colors.textSecondary,
              size: 22,
            ),
            tooltip: _isSearchExpanded ? 'Close Search' : 'Search',
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: Icon(
              filterState.showArchived
                  ? Icons.inbox_rounded
                  : Icons.archive_outlined,
              color: filterState.showArchived
                  ? colors.accentPrimary
                  : colors.textSecondary,
              size: 22,
            ),
            tooltip:
                filterState.showArchived ? 'View Active Inbox' : 'View Archive',
            onPressed: () {
              ref
                  .read(filterProvider.notifier)
                  .toggleArchived(!filterState.showArchived);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: colors.textSecondary,
              size: 22,
            ),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isSearchExpanded ? 98 : 46),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSearchExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: TextStyle(fontSize: 14, color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search title, content, tags, or URLs...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: colors.textTertiary,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: colors.textSecondary,
                              ),
                              onPressed: _clearSearch,
                            )
                          : null,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
              _buildFilterChipsRow(context, ref, filterState, colors),
            ],
          ),
        ),
      ),
      body: itemsAsync.when(
        loading: () => _buildLoadingState(colors),
        error: (err, _) => _buildErrorState(context, ref, err, colors),
        data: (items) {
          if (items.isEmpty) {
            return _buildEmptyState(context, ref, filterState, colors);
          }

          return RefreshIndicator(
            color: colors.accentPrimary,
            backgroundColor: colors.surfaceCard,
            onRefresh: () async {
              final repo = ref.read(itemRepositoryProvider);
              if (repo is SyncedItemRepository) {
                await repo.pullRemoteChanges();
              }
              ref.invalidate(activeItemsStreamProvider);
              ref.invalidate(archivedItemsStreamProvider);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildItemCard(context, ref, item, colors);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/editor/new'),
        tooltip: 'New Item',
        child: const Icon(Icons.add_rounded, size: 26),
      ),
    );
  }

  Widget _buildFilterChipsRow(
    BuildContext context,
    WidgetRef ref,
    FilterState filterState,
    StashlyColors colors,
  ) {
    final notifier = ref.read(filterProvider.notifier);
    final hasActiveFilters = filterState.typeFilter != null ||
        filterState.selectedTags.isNotEmpty ||
        filterState.query.isNotEmpty;

    // Collect all available tags across active items
    final allItemsAsync = filterState.showArchived
        ? ref.watch(archivedItemsStreamProvider)
        : ref.watch(activeItemsStreamProvider);

    final availableTags = allItemsAsync.maybeWhen(
      data: (items) {
        final tags = <String>{};
        for (final item in items) {
          tags.addAll(item.tags);
        }
        final list = tags.toList()..sort();
        return list;
      },
      orElse: () => const <String>[],
    );

    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterPill(
            label: 'All',
            icon: null,
            isSelected: filterState.typeFilter == null,
            onTap: () => notifier.setTypeFilter(null),
            colors: colors,
          ),
          const SizedBox(width: 6),
          _buildFilterPill(
            label: 'Notes',
            icon: Icons.description_outlined,
            isSelected: filterState.typeFilter == ItemType.note,
            onTap: () => notifier.setTypeFilter(ItemType.note),
            colors: colors,
          ),
          const SizedBox(width: 6),
          _buildFilterPill(
            label: 'Links',
            icon: Icons.link_rounded,
            isSelected: filterState.typeFilter == ItemType.link,
            onTap: () => notifier.setTypeFilter(ItemType.link),
            colors: colors,
          ),
          const SizedBox(width: 6),
          _buildFilterPill(
            label: 'Images',
            icon: Icons.image_outlined,
            isSelected: filterState.typeFilter == ItemType.image,
            onTap: () => notifier.setTypeFilter(ItemType.image),
            colors: colors,
          ),
          if (availableTags.isNotEmpty) ...[
            VerticalDivider(
              width: 16,
              thickness: 1,
              indent: 8,
              endIndent: 8,
              color: colors.surfaceBorder,
            ),
            for (final tag in availableTags) ...[
              _buildTagPill(
                tag: tag,
                isSelected: filterState.selectedTags.contains(tag),
                onTap: () => notifier.toggleTag(tag),
                colors: colors,
              ),
              const SizedBox(width: 6),
            ],
          ],
          if (hasActiveFilters) ...[
            const SizedBox(width: 4),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () {
                notifier.reset();
                _clearSearch();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: colors.surfaceSubtle,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.clear_all_rounded,
                        size: 14, color: colors.accentPrimary),
                    const SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colors.accentPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
    required StashlyColors colors,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colors.surfaceCard : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colors.accentPrimary : colors.surfaceBorder,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? colors.accentPrimary : colors.textSecondary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? colors.textPrimary : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagPill({
    required String tag,
    required bool isSelected,
    required VoidCallback onTap,
    required StashlyColors colors,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colors.accentPrimary : colors.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colors.accentPrimary : colors.surfaceBorder,
            width: 0.8,
          ),
        ),
        child: Text(
          '#$tag',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    WidgetRef ref,
    SavedItem item,
    StashlyColors colors,
  ) {
    final repo = ref.read(itemRepositoryProvider);
    final badgeColors = AppTheme.typeBadgeColors(item.type, colors);

    IconData typeIcon;
    String typeLabel;
    switch (item.type) {
      case ItemType.note:
        typeIcon = Icons.article_outlined;
        typeLabel = 'Note';
        break;
      case ItemType.link:
        typeIcon = Icons.link_rounded;
        typeLabel = 'Link';
        break;
      case ItemType.image:
        typeIcon = Icons.image_outlined;
        typeLabel = 'Image';
        break;
    }

    final relativeTime = _formatRelativeTime(item.updatedAt);
    final domainHost = item.url != null ? _extractHost(item.url!) : null;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: item.archived
              ? colors.statusSuccessContainer
              : colors.statusWarningContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.archived ? Icons.unarchive_outlined : Icons.archive_outlined,
              color: item.archived
                  ? colors.onStatusSuccessContainer
                  : colors.onStatusWarningContainer,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              item.archived ? 'Restore' : 'Archive',
              style: TextStyle(
                color: item.archived
                    ? colors.onStatusSuccessContainer
                    : colors.onStatusWarningContainer,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: colors.statusError.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.statusError.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: colors.statusError,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded,
                color: colors.statusError, size: 20),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context, item);
        } else {
          await repo.archiveItem(item.id, !item.archived);
          return false;
        }
      },
      onDismissed: (_) async {
        await repo.deleteItem(item.id);
      },
      child: Material(
        color: colors.surfaceCard,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.surfaceBorder, width: 1.0),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/item/${item.id}'),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row: Type Badge, Sync status, Reminder, Attachments, Timestamp & Options Menu
                Row(
                  children: [
                    // Content Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon,
                              size: 13, color: badgeColors.foreground),
                          const SizedBox(width: 4),
                          Text(
                            typeLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeColors.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Domain Host (for Links)
                    if (domainHost != null) ...[
                      Expanded(
                        child: Text(
                          domainHost,
                          style: context.stashlyTypography.monoHost,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ] else ...[
                      const Spacer(),
                    ],

                    // Outbox Sync indicator (real application state)
                    if (item.isDirty) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.statusWarningContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sync_rounded,
                                size: 11,
                                color: colors.onStatusWarningContainer),
                            const SizedBox(width: 3),
                            Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colors.onStatusWarningContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Reminder indicator
                    if (item.remindAt != null) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.notifications_active_outlined,
                        size: 14,
                        color: colors.statusWarning,
                      ),
                    ],

                    // Attachment indicator
                    if (item.attachmentPath != null) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.attach_file_rounded,
                        size: 14,
                        color: colors.textTertiary,
                      ),
                    ],

                    const SizedBox(width: 8),

                    // Relative Timestamp
                    Text(
                      relativeTime,
                      style: context.stashlyTypography.metaText.copyWith(
                        fontSize: 11.5,
                        color: colors.textTertiary,
                      ),
                    ),

                    // Overflow actions menu (non-gesture alternative)
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 18,
                        color: colors.textTertiary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                      tooltip: 'Item options',
                      onSelected: (val) async {
                        switch (val) {
                          case 'toggle_archive':
                            await repo.archiveItem(item.id, !item.archived);
                            break;
                          case 'edit':
                            context.push('/editor/${item.id}');
                            break;
                          case 'delete':
                            final confirmed =
                                await _showDeleteConfirmation(context, item);
                            if (confirmed == true) {
                              await repo.deleteItem(item.id);
                            }
                            break;
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined,
                                  size: 18, color: colors.textSecondary),
                              const SizedBox(width: 10),
                              const Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle_archive',
                          child: Row(
                            children: [
                              Icon(
                                item.archived
                                    ? Icons.unarchive_outlined
                                    : Icons.archive_outlined,
                                size: 18,
                                color: colors.textSecondary,
                              ),
                              const SizedBox(width: 10),
                              Text(item.archived ? 'Restore' : 'Archive'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 18, color: colors.statusError),
                              const SizedBox(width: 10),
                              Text(
                                'Delete',
                                style: TextStyle(color: colors.statusError),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Item Title
                Text(
                  item.title.isEmpty ? 'Untitled' : item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    letterSpacing: -0.15,
                    color: colors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Content snippet / excerpt
                if (item.content != null &&
                    item.content!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.content!.trim(),
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Tags row
                if (item.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: item.tags.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: colors.surfaceBorder,
                            width: 0.6,
                          ),
                        ),
                        child: Text(
                          '#$t',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
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

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    FilterState filterState,
    StashlyColors colors,
  ) {
    final isSearching = filterState.query.isNotEmpty ||
        filterState.typeFilter != null ||
        filterState.selectedTags.isNotEmpty;

    String title;
    String description;
    IconData icon;
    Widget? actionButton;

    if (isSearching) {
      icon = Icons.search_off_rounded;
      title = 'No matching items';
      description =
          'No saved notes, links, or images match your current search or filters.';
      actionButton = OutlinedButton.icon(
        onPressed: () {
          ref.read(filterProvider.notifier).reset();
          _clearSearch();
        },
        icon: const Icon(Icons.clear_all_rounded, size: 18),
        label: const Text('Clear search & filters'),
      );
    } else if (filterState.showArchived) {
      icon = Icons.archive_outlined;
      title = 'Archive is empty';
      description =
          'Items you archive from your inbox will be safely kept here.';
      actionButton = OutlinedButton.icon(
        onPressed: () {
          ref.read(filterProvider.notifier).toggleArchived(false);
        },
        icon: const Icon(Icons.arrow_back_rounded, size: 18),
        label: const Text('Back to active inbox'),
      );
    } else {
      icon = Icons.bookmark_border_rounded;
      title = 'Your inbox is clear';
      description =
          'Save articles, thoughts, code snippets, and pictures to read or reference later.';
      actionButton = FilledButton.icon(
        onPressed: () => context.push('/editor/new'),
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Create your first item'),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceSubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: colors.textTertiary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 20),
            actionButton,
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(StashlyColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: colors.accentPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Loading inbox...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    Object err,
    StashlyColors colors,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 44, color: colors.statusError),
            const SizedBox(height: 14),
            Text(
              'Unable to load items',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              err.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {
                ref.invalidate(activeItemsStreamProvider);
                ref.invalidate(archivedItemsStreamProvider);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(
      BuildContext context, SavedItem item) async {
    final colors = context.stashlyColors;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Item?'),
            content: Text(
              'Are you sure you want to permanently delete "${item.title.isEmpty ? 'Untitled' : item.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.statusError,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  static String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final local = dateTime.toLocal();
    final difference = now.difference(local);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (now.year == local.year) {
      return DateFormat.MMMd().format(local);
    } else {
      return DateFormat.yMMMd().format(local);
    }
  }

  static String? _extractHost(String rawUrl) {
    final uri = Uri.tryParse(rawUrl);
    if (uri != null && uri.host.isNotEmpty) {
      return uri.host.replaceFirst(RegExp(r'^www\.'), '');
    }
    return rawUrl;
  }
}
