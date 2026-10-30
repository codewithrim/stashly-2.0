import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stashly/core/theme.dart';
import 'package:stashly/data/models/item.dart';
import 'package:stashly/data/repositories/item_repository.dart';
import 'package:stashly/data/services/share_parser.dart';
import 'package:stashly/features/editor/editor_screen.dart';
import 'package:stashly/features/providers.dart';

class FakeEditorItemRepository implements ItemRepository {
  List<SavedItem> items = [];
  SavedItem? lastSavedItem;

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
    lastSavedItem = item;
    final idx = items.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      items[idx] = item;
    } else {
      items.add(item);
    }
  }

  @override
  Future<void> archiveItem(String id, bool archive) async {}

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
  }) async =>
      items;

  @override
  Future<void> wipeLocalData() async {
    items.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildEditor({
    required FakeEditorItemRepository repo,
    String itemId = 'new',
    SharedPayload? sharedPayload,
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return ProviderScope(
      overrides: [
        itemRepositoryProvider.overrideWithValue(repo),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: EditorScreen(
          itemId: itemId,
          initialSharedPayload: sharedPayload,
        ),
      ),
    );
  }

  group('EditorScreen UI/UX & Flow Tests', () {
    testWidgets('Renders notebook writing surface with clean fields',
        (tester) async {
      final repo = FakeEditorItemRepository();

      await tester.pumpWidget(buildEditor(repo: repo, itemId: 'new'));
      await tester.pumpAndSettle();

      expect(find.text('New Entry'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Entry Title'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
      expect(find.text('Link'), findsOneWidget);
      expect(find.text('Image'), findsOneWidget);
      expect(find.text('Resurface Later'), findsOneWidget);
      expect(find.text('Attachment'), findsOneWidget);
      expect(find.text('Tags'), findsOneWidget);
    });

    testWidgets(
        'Content-type switching preserves content and reveals URL field',
        (tester) async {
      final repo = FakeEditorItemRepository();

      await tester.pumpWidget(buildEditor(repo: repo, itemId: 'new'));
      await tester.pumpAndSettle();

      // Enter a title and content in Note mode
      await tester.enterText(
          find.widgetWithText(TextField, 'Entry Title'), 'Article Review');
      await tester.enterText(
          find.byWidgetPredicate((w) =>
              w is TextField &&
              w.decoration?.hintText?.contains('Start writing') == true),
          'Reflections on systems design');

      // Switch to Link
      await tester.tap(find.text('Link'));
      await tester.pumpAndSettle();

      // Title and content must be preserved
      expect(find.text('Article Review'), findsOneWidget);
      expect(find.text('Reflections on systems design'), findsOneWidget);
      expect(find.byIcon(Icons.link_rounded), findsWidgets);
    });

    testWidgets('Tag input adds clean tags and deduplicates correctly',
        (tester) async {
      final repo = FakeEditorItemRepository();

      await tester.pumpWidget(buildEditor(repo: repo, itemId: 'new'));
      await tester.pumpAndSettle();

      // Add a tag with #
      final tagField =
          find.widgetWithText(TextField, 'Add a tag (e.g. design, reading)');
      await tester.ensureVisible(tagField);
      await tester.pumpAndSettle();

      await tester.enterText(tagField, '#design');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('#design'), findsOneWidget);
      expect(find.text('1/20'), findsOneWidget);

      // Add duplicate tag with uppercase and whitespace
      await tester.enterText(tagField, ' DESIGN ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Duplicate should be ignored
      expect(find.text('#design'), findsOneWidget);
      expect(find.text('1/20'), findsOneWidget);

      // Remove the tag
      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await tester.pumpAndSettle();

      expect(find.text('#design'), findsNothing);
      expect(find.text('0/20'), findsOneWidget);
    });

    testWidgets(
        'Validation blocks invalid links and displays clean inline error',
        (tester) async {
      final repo = FakeEditorItemRepository();

      await tester.pumpWidget(buildEditor(repo: repo, itemId: 'new'));
      await tester.pumpAndSettle();

      // Switch to Link
      await tester.tap(find.text('Link'));
      await tester.pumpAndSettle();

      // Tap Save with empty URL
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('A link item requires a valid URL.'), findsOneWidget);
      expect(repo.lastSavedItem, isNull);
    });

    testWidgets('Loads existing item for editing and updates cleanly',
        (tester) async {
      final existingItem = SavedItem(
        id: 'item-101',
        ownerId: 'user-1',
        type: ItemType.note,
        title: 'Original Title',
        content: 'Original Content',
        tags: const ['research', 'books'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = FakeEditorItemRepository()..items = [existingItem];

      await tester.pumpWidget(buildEditor(repo: repo, itemId: 'item-101'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Entry'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
      expect(find.text('Original Title'), findsOneWidget);
      expect(find.text('Original Content'), findsOneWidget);
      expect(find.text('#research'), findsOneWidget);
      expect(find.text('#books'), findsOneWidget);

      // Modify the title and save
      await tester.enterText(
          find.widgetWithText(TextField, 'Original Title'), 'Updated Title');
      await tester.tap(find.text('Update'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(repo.lastSavedItem, isNotNull);
      expect(repo.lastSavedItem!.id, 'item-101');
      expect(repo.lastSavedItem!.title, 'Updated Title');
    });

    testWidgets('Renders properly in Dark Mode without contrast issues',
        (tester) async {
      final repo = FakeEditorItemRepository();

      await tester.pumpWidget(buildEditor(
        repo: repo,
        itemId: 'new',
        themeMode: ThemeMode.dark,
      ));
      await tester.pumpAndSettle();

      expect(find.text('New Entry'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
    });

    testWidgets('Save button text and checkmark icon are white across themes',
        (tester) async {
      final repo = FakeEditorItemRepository();

      // Test dark theme
      await tester.pumpWidget(buildEditor(
        repo: repo,
        itemId: 'new',
        themeMode: ThemeMode.dark,
      ));
      await tester.pumpAndSettle();

      final saveText = tester.widget<Text>(find.text('Save'));
      expect(saveText.style?.color, Colors.white);

      final checkIcon = tester.widget<Icon>(find.byIcon(Icons.check_rounded));
      expect(checkIcon.color, Colors.white);

      // Test light theme
      await tester.pumpWidget(buildEditor(
        repo: repo,
        itemId: 'new',
        themeMode: ThemeMode.light,
      ));
      await tester.pumpAndSettle();

      final lightSaveText = tester.widget<Text>(find.text('Save'));
      expect(lightSaveText.style?.color, Colors.white);

      final lightCheckIcon =
          tester.widget<Icon>(find.byIcon(Icons.check_rounded));
      expect(lightCheckIcon.color, Colors.white);
    });

    testWidgets(
        'Saving a new note completes cleanly without yellow error popup',
        (tester) async {
      final repo = FakeEditorItemRepository();

      await tester.pumpWidget(buildEditor(
        repo: repo,
        itemId: 'new',
        themeMode: ThemeMode.dark,
      ));
      await tester.pumpAndSettle();

      // Enter note content
      final contentField = find.byWidgetPredicate((w) =>
          w is TextField &&
          w.decoration?.hintText?.contains('Start writing') == true);
      await tester.enterText(contentField, 'Fresh stashed note content');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify item saved to repository
      expect(repo.lastSavedItem, isNotNull);
      expect(repo.lastSavedItem!.content, 'Fresh stashed note content');
      expect(repo.lastSavedItem!.title, 'Fresh stashed note content');

      // Verify NO yellow diagnostic or error banner appeared
      expect(find.byIcon(Icons.info_outline_rounded), findsNothing);
      expect(find.textContaining('Failed to save'), findsNothing);
    });

    testWidgets(
        'Custom DatePicker dialog displays Cancel in muted blue-grey and OK in honey yellow',
        (tester) async {
      final repo = FakeEditorItemRepository();

      await tester.pumpWidget(buildEditor(
        repo: repo,
        itemId: 'new',
        themeMode: ThemeMode.dark,
      ));
      await tester.pumpAndSettle();

      // Scroll and open reminder sheet
      final reminderTile = find.text('Resurface Later');
      await tester.ensureVisible(reminderTile);
      await tester.tap(reminderTile);
      await tester.pumpAndSettle();

      // Tap Pick custom date & time
      await tester.tap(find.text('Pick custom date & time'));
      await tester.pumpAndSettle();

      // DatePicker should be open
      expect(find.byType(DatePickerDialog), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      final cancelButton = tester.widget<TextButton>(
          find.widgetWithText(TextButton, 'Cancel'));
      final okButton = tester.widget<TextButton>(
          find.widgetWithText(TextButton, 'OK'));

      final cancelColor =
          cancelButton.style?.foregroundColor?.resolve({}) ??
              cancelButton.style?.textStyle?.resolve({})?.color;
      final okColor =
          okButton.style?.foregroundColor?.resolve({}) ??
              okButton.style?.textStyle?.resolve({})?.color;

      expect(cancelColor, const Color(0xFF94A3B8),
          reason: 'Cancel button should be muted light blue-grey');
      expect(okColor, const Color(0xFFF2C66D),
          reason: 'OK button should be prominent honey yellow');
    });
  });
}
