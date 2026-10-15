import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/item.dart';
import '../providers.dart';

class FilterState {
  final String query;
  final ItemType? typeFilter;
  final Set<String> selectedTags;
  final bool showArchived;

  const FilterState({
    this.query = '',
    this.typeFilter,
    this.selectedTags = const {},
    this.showArchived = false,
  });

  FilterState copyWith({
    String? query,
    ItemType? typeFilter,
    bool clearTypeFilter = false,
    Set<String>? selectedTags,
    bool? showArchived,
  }) {
    return FilterState(
      query: query ?? this.query,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      selectedTags: selectedTags ?? this.selectedTags,
      showArchived: showArchived ?? this.showArchived,
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setQuery(String q) => state = state.copyWith(query: q);
  void setTypeFilter(ItemType? type) {
    if (state.typeFilter == type) {
      state = state.copyWith(clearTypeFilter: true);
    } else {
      state = state.copyWith(typeFilter: type);
    }
  }

  void toggleTag(String tag) {
    final nextTags = Set<String>.from(state.selectedTags);
    if (nextTags.contains(tag)) {
      nextTags.remove(tag);
    } else {
      nextTags.add(tag);
    }
    state = state.copyWith(selectedTags: nextTags);
  }

  void toggleArchived(bool archived) {
    state = state.copyWith(showArchived: archived);
  }

  void reset() => state = const FilterState();
}

final filterProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});

final filteredItemsProvider = Provider<AsyncValue<List<SavedItem>>>((ref) {
  final filter = ref.watch(filterProvider);
  final itemsAsync = filter.showArchived
      ? ref.watch(archivedItemsStreamProvider)
      : ref.watch(activeItemsStreamProvider);

  return itemsAsync.whenData((items) {
    return items.where((item) {
      if (filter.typeFilter != null && item.type != filter.typeFilter) {
        return false;
      }
      if (filter.selectedTags.isNotEmpty) {
        final hasAll = filter.selectedTags
            .every((t) => item.tags.contains(t.toLowerCase()));
        if (!hasAll) return false;
      }
      if (filter.query.trim().isNotEmpty) {
        final q = filter.query.trim().toLowerCase();
        final matchesTitle = item.title.toLowerCase().contains(q);
        final matchesContent = item.content?.toLowerCase().contains(q) ?? false;
        final matchesUrl = item.url?.toLowerCase().contains(q) ?? false;
        final matchesTags = item.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchesTitle && !matchesContent && !matchesUrl && !matchesTags) {
          return false;
        }
      }
      return true;
    }).toList();
  });
});
