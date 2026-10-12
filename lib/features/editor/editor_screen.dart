import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/errors.dart';
import '../../core/validators.dart';
import '../../data/models/item.dart';
import '../../data/services/attachment_service.dart';
import '../../data/services/share_parser.dart';
import '../providers.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final String itemId;
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

  // Attachment state
  File? _pickedFile;
  String? _attachmentName;
  String? _attachmentMime;
  String? _existingAttachmentPath;

  // Reminder state (Mission D)
  DateTime? _remindAt;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialSharedPayload?.type ?? ItemType.note;
    _titleController = TextEditingController(text: widget.initialSharedPayload?.title ?? '');
    _contentController = TextEditingController(text: widget.initialSharedPayload?.content ?? '');
    _urlController = TextEditingController(text: widget.initialSharedPayload?.url ?? '');
    _tagInputController = TextEditingController();

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
        _attachmentName = item.attachmentName;
        _attachmentMime = item.attachmentMime;
        _existingAttachmentPath = item.attachmentPath;
        _remindAt = item.remindAt;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _urlController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (image != null) {
      final file = File(image.path);
      final size = await file.length();
      if (size > AttachmentService.maxSizeBytes) {
        setState(() => _errorMessage = 'Image size exceeds the 10 MB limit.');
        return;
      }
      setState(() {
        _pickedFile = file;
        _attachmentName = image.name;
        _attachmentMime = image.mimeType ?? 'image/jpeg';
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final size = await file.length();
      if (size > AttachmentService.maxSizeBytes) {
        setState(() => _errorMessage = 'PDF size exceeds the 10 MB limit.');
        return;
      }
      setState(() {
        _pickedFile = file;
        _attachmentName = result.files.single.name;
        _attachmentMime = 'application/pdf';
        _errorMessage = null;
      });
    }
  }

  Future<void> _showReminderPicker() async {
    final now = DateTime.now();
    final tomorrow9am = DateTime(now.year, now.month, now.day + 1, 9, 0);
    final nextWeek9am = DateTime(now.year, now.month, now.day + 7, 9, 0);

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Resurface Item Later', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              ListTile(
                leading: const Icon(Icons.wb_sunny_outlined, color: Colors.amber),
                title: const Text('Tomorrow morning (9:00 AM)'),
                onTap: () {
                  setState(() => _remindAt = tomorrow9am);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.date_range_outlined, color: Colors.blue),
                title: const Text('In 7 days (9:00 AM)'),
                onTap: () {
                  setState(() => _remindAt = nextWeek9am);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_calendar_outlined, color: Colors.purple),
                title: const Text('Pick custom date & time'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: now.add(const Duration(days: 1)),
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                  );
                  if (pickedDate != null && mounted) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _remindAt = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              if (_remindAt != null)
                ListTile(
                  leading: const Icon(Icons.notifications_off_outlined, color: Colors.red),
                  title: const Text('Clear reminder', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    setState(() => _remindAt = null);
                    Navigator.pop(ctx);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _addTag(String raw) {
    if (raw.trim().isEmpty) return;
    final sanitized = Validators.sanitizeTags([..._tags, raw]);
    setState(() {
      _tags = sanitized;
      _tagInputController.clear();
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _handleSave() async {
    setState(() => _errorMessage = null);

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

    if (_selectedType == ItemType.image && _pickedFile == null && _existingAttachmentPath == null) {
      setState(() => _errorMessage = 'An image item requires an attached photo or graphic.');
      return;
    }

    if (_selectedType == ItemType.note &&
        (sanitizedTitle == 'Untitled' && (sanitizedContent == null || sanitizedContent.isEmpty))) {
      setState(() => _errorMessage = 'Please provide either a title or note content.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(itemRepositoryProvider);
      final isNew = widget.itemId == 'new';

      var finalAttachmentPath = _existingAttachmentPath;
      var finalAttachmentName = _attachmentName;
      var finalAttachmentMime = _attachmentMime;

      if (_pickedFile != null && _attachmentName != null && _attachmentMime != null) {
        final attachmentService = ref.read(attachmentServiceProvider);
        final meta = await attachmentService.uploadAttachment(
          itemId: isNew ? 'draft' : widget.itemId,
          file: _pickedFile!,
          rawFilename: _attachmentName!,
          mimeType: _attachmentMime!,
        );
        finalAttachmentPath = meta.path;
        finalAttachmentName = meta.name;
        finalAttachmentMime = meta.mime;
      }

      final item = SavedItem.create(
        id: isNew ? null : widget.itemId,
        type: _selectedType,
        title: sanitizedTitle,
        content: sanitizedContent,
        url: validatedUrl,
        tags: _tags,
        remindAt: _remindAt,
        attachmentPath: finalAttachmentPath,
        attachmentName: finalAttachmentName,
        attachmentMime: finalAttachmentMime,
      );

      await repo.saveItem(item);

      // Schedule or cancel local notification
      final reminderService = ref.read(reminderServiceProvider);
      if (_remindAt != null) {
        await reminderService.requestPermission();
        await reminderService.scheduleReminder(
          itemId: item.id,
          title: item.title,
          scheduledDate: _remindAt!,
        );
      } else {
        await reminderService.cancelReminder(item.id);
      }

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
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Content / Snippet',
                hintText: 'Type your thoughts, code, or markdown snippet...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Reminder Option Card (Mission D)
            Card(
              child: ListTile(
                leading: Icon(
                  _remindAt != null ? Icons.notifications_active : Icons.notifications_none,
                  color: _remindAt != null ? Colors.amber.shade700 : null,
                ),
                title: Text(
                  _remindAt != null
                      ? 'Reminder: ${DateFormat.yMMMd().add_jm().format(_remindAt!)}'
                      : 'Resurface Later (Reminder)',
                  style: TextStyle(
                    fontWeight: _remindAt != null ? FontWeight.bold : FontWeight.normal,
                    color: _remindAt != null ? Colors.amber.shade900 : null,
                  ),
                ),
                subtitle: Text(_remindAt != null ? 'Tap to modify or clear' : 'Tomorrow 9am, next week, or custom date'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showReminderPicker,
              ),
            ),
            const SizedBox(height: 16),

            // Attachment Picker Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Attachment (Images or PDF, Max 10MB)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    if (_attachmentName != null || _pickedFile != null) ...[
                      Row(
                        children: [
                          Icon(
                            _attachmentMime == 'application/pdf' ? Icons.picture_as_pdf : Icons.image,
                            color: const Color(0xFF6366F1),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _attachmentName ?? _pickedFile!.path.split('/').last,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setState(() {
                                _pickedFile = null;
                                _attachmentName = null;
                                _attachmentMime = null;
                                _existingAttachmentPath = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library_outlined, size: 18),
                            label: const Text('Add Image'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _pickPdf,
                            icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                            label: const Text('Add PDF'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
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
