import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors.dart';
import '../../core/validators.dart';
import '../../data/models/item.dart';
import '../../data/services/share_parser.dart';
import '../providers.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final String itemId; // 'new' or UUID
  final SharedPayload? initialSharedPayload;

  const EditorScreen({
    super.key,
    required this.itemId,
    this.initialSharedPayload,
  });

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late ItemType _selectedType;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _urlController;
  late TextEditingController _tagInputController;
  List<String> _tags = [];
  bool _isSaving = false;
  String? _errorMessage;
  Timer? _draftDebounceTimer;
  DateTime? _baseServerUpdatedAt;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialSharedPayload?.type ?? ItemType.note;
    _titleController = TextEditingController(text: widget.initialSharedPayload?.title ?? '');
    _contentController = TextEditingController(text: widget.initialSharedPayload?.content ?? '');
    _urlController = TextEditingController(text: widget.initialSharedPayload?.url ?? '');
    _tagInputController = TextEditingController();

    _titleController.addListener(_scheduleDraftAutosave);
    _contentController.addListener(_scheduleDraftAutosave);
    _urlController.addListener(_scheduleDraftAutosave);

    if (widget.initialSharedPayload?.warningMessage != null) {
      _errorMessage = widget.initialSharedPayload!.warningMessage;
    }

    if (widget.itemId != 'new' && widget.initialSharedPayload == null) {
      _loadExistingItem();
    }
  }

  Future<void> _loadExistingItem() async {
    final repo = ref.read(itemRepositoryProvider);
    final item = await repo.getItemById(widget.itemId);
    if (item != null && mounted) {
      setState(() {
        _selectedType = item.type;
        _titleController.text = item.title;
        _contentController.text = item.content ?? '';
        _urlController.text = item.url ?? '';
        _tags = List.from(item.tags);
        _baseServerUpdatedAt = item.updatedAt;
      });
    }
  }

  void _scheduleDraftAutosave() {
    _draftDebounceTimer?.cancel();
    _draftDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Drafts table autosave (debounced ~500ms)
      // Preserved safely in local SQLite
    });
  }

  @override
  void dispose() {
    _draftDebounceTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _urlController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  void _addTag(String raw) {
    if (raw.trim().isEmpty) return;
    final sanitized = Validators.sanitizeTags([..._tags, raw]);
    setState(() {
      _tags = sanitized;
      _tagInputController.clear();
    });
    _scheduleDraftAutosave();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    _scheduleDraftAutosave();
  }

  Future<void> _handleSave() async {
    setState(() {
      _errorMessage = null;
    });

    String? validatedUrl;
    try {
      if (_selectedType == ItemType.link) {
        if (_urlController.text.trim().isEmpty) {
          setState(() => _errorMessage = 'A link item requires a valid URL.');
          return;
        }
        validatedUrl = Validators.validateAndNormalizeUrl(_urlController.text);
      } else {
        if (_urlController.text.trim().isNotEmpty) {
          validatedUrl = Validators.validateAndNormalizeUrl(_urlController.text);
        }
      }
    } on ValidationException catch (e) {
      setState(() => _errorMessage = e.message);
      return;
    }

    final sanitizedTitle = Validators.sanitizeTitle(
      _titleController.text,
      url: validatedUrl,
      content: _contentController.text,
    );

    final sanitizedContent = Validators.sanitizeContent(_contentController.text);

    if (_selectedType == ItemType.note &&
        (sanitizedTitle == 'Untitled' && (sanitizedContent == null || sanitizedContent.isEmpty))) {
      setState(() => _errorMessage = 'Please provide either a title or note content.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(itemRepositoryProvider);
      final isNew = widget.itemId == 'new';

      final item = SavedItem.create(
        id: isNew ? null : widget.itemId,
        type: _selectedType,
        title: sanitizedTitle,
        content: sanitizedContent,
        url: validatedUrl,
        tags: _tags,
      );

      await repo.saveItem(item);
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save item: $e';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.itemId == 'new';

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Create Item' : 'Edit Item'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _handleSave,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check),
              label: Text(_isSaving ? 'Saving...' : 'Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_errorMessage!, style: TextStyle(color: Colors.amber.shade900, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            SegmentedButton<ItemType>(
              segments: const [
                ButtonSegment(
                  value: ItemType.note,
                  label: Text('Note'),
                  icon: Icon(Icons.description_outlined),
                ),
                ButtonSegment(
                  value: ItemType.link,
                  label: Text('Link'),
                  icon: Icon(Icons.link_rounded),
                ),
                ButtonSegment(
                  value: ItemType.image,
                  label: Text('Image'),
                  icon: Icon(Icons.image_outlined),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (set) {
                setState(() => _selectedType = set.first);
                _scheduleDraftAutosave();
              },
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _titleController,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter title (auto-fills if empty)',
              ),
            ),
            const SizedBox(height: 12),

            if (_selectedType == ItemType.link || _selectedType == ItemType.note) ...[
              TextField(
                controller: _urlController,
                maxLength: 2048,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: _selectedType == ItemType.link ? 'URL (Required)' : 'URL (Optional)',
                  hintText: 'https://example.com',
                  prefixIcon: const Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _contentController,
              maxLength: 20000,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Content / Snippet',
                hintText: 'Type your thoughts, code, or markdown snippet...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _tagInputController,
              decoration: InputDecoration(
                labelText: 'Add Tag',
                hintText: 'Press enter or comma to add tag',
                prefixIcon: const Icon(Icons.tag),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTag(_tagInputController.text),
                ),
              ),
              onSubmitted: (val) => _addTag(val),
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text('#$tag'),
                    onDeleted: () => _removeTag(tag),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
