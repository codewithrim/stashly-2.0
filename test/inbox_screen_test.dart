import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stashly/core/theme.dart';
import 'package:stashly/data/models/item.dart';
import 'package:stashly/data/repositories/item_repository.dart';
import 'package:stashly/features/inbox/inbox_screen.dart';
import 'package:stashly/features/providers.dart';

class FakeItemRepository implements ItemRepository {
  List<SavedItem> items = [];

  @override
  Stream<List<SavedItem>> watchActiveItems() =>
      Stream.value(items.where((i) => !i.archived).toList());

  @override
  Stream<List<SavedItem>> watchArchivedItems() =>
      Stream.value(items.where((i) => i.archived).toList());

  @override
  Future<SavedItem?> getItemById(String id) async {
    return items.cast<SavedItem?>().firstWhere(
          (i) => i?.id == id,
          orElse: () => null,
        );
  }

  @override
  Future<void> saveItem(SavedItem item) async {
    final idx = items.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      items[idx] = item;
    } else {
      items.add(item);
    }
  }

  @override
  Future<void> archiveItem(String id, bool archive) async {
    final idx = items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(archived: archive);
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    items.removeWhere((i) => i.id == id);
  }

  @override
  Future<List<SavedItem>> searchItems({
    String? query,
    ItemType? typeFilter,
    List<String>? tagFilters,
    bool archived = false,
  }) async {
    return items;
  }

  @override
  Future<void> wipeLocalData() async {
    items.clear();
  }
}

void main() {
  Widget buildTestableWidget({
    required FakeItemRepository repo,
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return ProviderScope(
      overrides: [
        itemRepositoryProvider.overrideWithValue(repo),
        activeItemsStreamProvider
            .overrideWith((ref) => repo.watchActiveItems()),
        archivedItemsStreamProvider
            .overrideWith((ref) => repo.watchArchivedItems()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const InboxScreen(),
      ),
    );
  }

  group('InboxScreen UI/UX Tests', () {
    testWidgets('Renders empty inbox state when no items exist',
        (tester) async {
      final repo = FakeItemRepository();

      await tester.pumpWidget(buildTestableWidget(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('Stashly'), findsOneWidget);
      expect(find.text('0 items'), findsOneWidget);
      expect(find.text('Your inbox is clear'), findsOneWidget);
      expect(find.text('Create your first item'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Renders items with type badge, title, relative time, and tags',
        (tester) async {
      final repo = FakeItemRepository()
        ..items = [
          SavedItem(
            id: '1',
            ownerId: 'u1',
            type: ItemType.note,
            title: 'Refined Typography in Mobile UI',
            content: 'Exploring editorial aesthetics and reading comfort.',
            tags: const ['design', 'flutter'],
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          SavedItem(
            id: '2',
            ownerId: 'u1',
            type: ItemType.link,
            title: 'Flutter Architecture Guide',
            url: 'https://flutter.dev/docs',
            tags: const ['dev'],
            isDirty: true,
            createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
            updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
          ),
        ];

      await tester.pumpWidget(buildTestableWidget(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('2 items'), findsOneWidget);
      expect(find.text('Refined Typography in Mobile UI'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
      expect(find.text('Flutter Architecture Guide'), findsOneWidget);
      expect(find.text('Link'), findsOneWidget);
      expect(find.text('flutter.dev'), findsOneWidget);
      expect(find.text('#design'), findsAtLeastNWidgets(1));
      expect(find.text('#flutter'), findsAtLeastNWidgets(1));
      expect(find.text('Pending'), findsOneWidget); // Real sync indicator
    });

    testWidgets('Search button expands search bar and filters items',
        (tester) async {
      final repo = FakeItemRepository()
        ..items = [
          SavedItem(
            id: '1',
            ownerId: 'u1',
            type: ItemType.note,
            title: 'Shopping List',
            content: 'Milk, bread, coffee',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          SavedItem(
            id: '2',
            ownerId: 'u1',
            type: ItemType.note,
            title: 'Project Ideas',
            content: 'Save-for-later Flutter app',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

      await tester.pumpWidget(buildTestableWidget(repo: repo));
      await tester.pumpAndSettle();

      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Project Ideas'), findsOneWidget);

      // Tap search icon button in AppBar
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();

      // Enter search text
      await tester.enterText(find.byType(TextField), 'Project');
      await tester.pumpAndSettle();

      expect(find.text('Project Ideas'), findsOneWidget);
      expect(find.text('Shopping List'), findsNothing);
    });

    testWidgets('Filter pills filter by content type (Notes/Links/Images)',
        (tester) async {
      final repo = FakeItemRepository()
        ..items = [
          SavedItem(
            id: '1',
            ownerId: 'u1',
            type: ItemType.note,
            title: 'Just a note',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          SavedItem(
            id: '2',
            ownerId: 'u1',
            type: ItemType.link,
            title: 'Dart Language Tour',
            url: 'https://dart.dev',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

      await tester.pumpWidget(buildTestableWidget(repo: repo));
      await tester.pumpAndSettle();

      // Tap 'Links' filter pill
      await tester.tap(find.text('Links'));
      await tester.pumpAndSettle();

      expect(find.text('Dart Language Tour'), findsOneWidget);
      expect(find.text('Just a note'), findsNothing);

      // Tap 'Clear'
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(find.text('Dart Language Tour'), findsOneWidget);
      expect(find.text('Just a note'), findsOneWidget);
    });

    testWidgets('Renders correctly in Dark Mode', (tester) async {
      final repo = FakeItemRepository()
        ..items = [
          SavedItem(
            id: '1',
            ownerId: 'u1',
            type: ItemType.note,
            title: 'Night Reading Snippet',
            content: 'Dark mode contrast validation.',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

      await tester.pumpWidget(buildTestableWidget(
        repo: repo,
        themeMode: ThemeMode.dark,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Night Reading Snippet'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
    });

    testWidgets(
        'Renders long titles without overflow and items with no content',
        (tester) async {
      final repo = FakeItemRepository()
        ..items = [
          SavedItem(
            id: 'long',
            ownerId: 'u1',
            type: ItemType.note,
            title:
                'This is an exceptionally long title designed to test text wrapping and truncation across multiple lines on small mobile screens without causing any RenderFlex overflows.',
            content: null, // No excerpt
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

      await tester.pumpWidget(buildTestableWidget(repo: repo));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('This is an exceptionally long title'),
        findsOneWidget,
      );
      // No overflow exceptions thrown!
      expect(tester.takeException(), isNull);
    });

    testWidgets('Item card popup menu triggers edit and delete options',
        (tester) async {
      final repo = FakeItemRepository()
        ..items = [
          SavedItem(
            id: 'opt',
            ownerId: 'u1',
            type: ItemType.note,
            title: 'Action Item',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

      await tester.pumpWidget(buildTestableWidget(repo: repo));
      await tester.pumpAndSettle();

      // Tap options menu icon
      await tester.tap(find.byTooltip('Item options'));
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Tap delete in menu to trigger confirmation dialog
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Item?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Item?'), findsNothing);
      expect(find.text('Action Item'), findsOneWidget);
    });
  });
}
