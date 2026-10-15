import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/errors.dart';
import '../../core/theme.dart';
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
  bool _isDirty = false;

  // Attachment state
  File? _pickedFile;
  String? _attachmentName;
  String? _attachmentMime;
  String? _existingAttachmentPath;

  // Reminder state (Mission D)
  DateTime? _remindAt;

  // Autosave draft debouncer (Mission A / Section 5.2)
  Timer? _draftDebounceTimer;

  // Baseline snapshot for change tracking
  String _baselineTitle = '';
  String _baselineContent = '';
  String _baselineUrl = '';
  List<String> _baselineTags = [];
  ItemType _baselineType = ItemType.note;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialSharedPayload?.type ?? ItemType.note;
    _baselineType = _selectedType;
    _titleController =
        TextEditingController(text: widget.initialSharedPayload?.title ?? '');
    _contentController =
        TextEditingController(text: widget.initialSharedPayload?.content ?? '');
    _urlController =
        TextEditingController(text: widget.initialSharedPayload?.url ?? '');
    _tagInputController = TextEditingController();

    _titleController.addListener(_onFieldChanged);
    _contentController.addListener(_onFieldChanged);
    _urlController.addListener(_onFieldChanged);

    if (widget.initialSharedPayload?.warningMessage != null) {
      _errorMessage = widget.initialSharedPayload!.warningMessage;
    }

    if (widget.itemId != 'new' && widget.initialSharedPayload == null) {
      _loadExistingItem();
    } else if (widget.itemId == 'new' && widget.initialSharedPayload == null) {
      _restoreDraft();
    }
  }

  void _onFieldChanged() {
    _updateDirtyState();
    _scheduleDraftAutosave();
  }

  void _updateDirtyState() {
    final changed = _titleController.text != _baselineTitle ||
        _contentController.text != _baselineContent ||
        _urlController.text != _baselineUrl ||
        _selectedType != _baselineType ||
        _tags.length != _baselineTags.length ||
        _pickedFile != null ||
        _remindAt != null;

    if (_isDirty != changed) {
      setState(() => _isDirty = changed);
    }
  }

  void _scheduleDraftAutosave() {
    _draftDebounceTimer?.cancel();
    _draftDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _persistDraft();
    });
  }

  Future<void> _persistDraft() async {
    if (!mounted) return;
    try {
      final db = ref.read(databaseProvider);
      final hasData = _titleController.text.trim().isNotEmpty ||
          _contentController.text.trim().isNotEmpty ||
          _urlController.text.trim().isNotEmpty ||
          _tags.isNotEmpty;

      if (hasData) {
        await db.saveDraft(
          targetId: widget.itemId,
          type: _selectedType.name,
          title: _titleController.text,
          content: _contentController.text,
          url: _urlController.text,
          tags: _tags,
        );
      }
    } catch (_) {
      // Non-blocking draft autosave
    }
  }

  Future<void> _restoreDraft() async {
    try {
      final db = ref.read(databaseProvider);
      final draft = await db.getDraft(widget.itemId);
      if (draft != null && mounted) {
        _titleController.removeListener(_onFieldChanged);
        _contentController.removeListener(_onFieldChanged);
        _urlController.removeListener(_onFieldChanged);

        setState(() {
          _selectedType = ItemType.fromString(draft.type);
          _baselineType = _selectedType;
          _titleController.text = draft.title ?? '';
          _baselineTitle = _titleController.text;
          _contentController.text = draft.content ?? '';
          _baselineContent = _contentController.text;
          _urlController.text = draft.url ?? '';
          _baselineUrl = _urlController.text;
          try {
            _tags = Validators.sanitizeTags(
                List<String>.from(draft.tags as Iterable<dynamic>));
          } catch (_) {
            _tags = [];
          }
          _baselineTags = List.from(_tags);
        });

        _titleController.addListener(_onFieldChanged);
        _contentController.addListener(_onFieldChanged);
        _urlController.addListener(_onFieldChanged);
      }
    } catch (_) {}
  }

  Future<void> _loadExistingItem() async {
    final repo = ref.read(itemRepositoryProvider);
    final item = await repo.getItemById(widget.itemId);
    if (item != null && mounted) {
      _titleController.removeListener(_onFieldChanged);
      _contentController.removeListener(_onFieldChanged);
      _urlController.removeListener(_onFieldChanged);

      setState(() {
        _selectedType = item.type;
        _baselineType = item.type;
        _titleController.text = item.title;
        _baselineTitle = item.title;
        _contentController.text = item.content ?? '';
        _baselineContent = item.content ?? '';
        _urlController.text = item.url ?? '';
        _baselineUrl = item.url ?? '';
        _tags = List.from(item.tags);
        _baselineTags = List.from(item.tags);
        _attachmentName = item.attachmentName;
        _attachmentMime = item.attachmentMime;
        _existingAttachmentPath = item.attachmentPath;
        _remindAt = item.remindAt;
      });

      _titleController.addListener(_onFieldChanged);
      _contentController.addListener(_onFieldChanged);
      _urlController.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    _draftDebounceTimer?.cancel();
    _titleController.removeListener(_onFieldChanged);
    _contentController.removeListener(_onFieldChanged);
    _urlController.removeListener(_onFieldChanged);
    _titleController.dispose();
    _contentController.dispose();
    _urlController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
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
        _onFieldChanged();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Could not select photo: $e');
    }
  }

  Future<void> _pickPdf() async {
    try {
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
        _onFieldChanged();
      }
    } catch (e) {
      setState(() => _errorMessage = 'Could not select document: $e');
    }
  }

  Future<void> _showReminderPicker() async {
    final colors = context.stashlyColors;
    final now = DateTime.now();
    final tomorrow9am = DateTime(now.year, now.month, now.day + 1, 9, 0);
    final nextWeek9am = DateTime(now.year, now.month, now.day + 7, 9, 0);

    await showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      Icon(Icons.alarm_rounded,
                          size: 18, color: colors.accentPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'Set Resurface Reminder',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: colors.surfaceBorder, height: 1),
                ListTile(
                  leading: Icon(Icons.wb_sunny_outlined,
                      color: colors.accentPrimary, size: 20),
                  title: Text('Tomorrow morning (9:00 AM)',
                      style:
                          TextStyle(fontSize: 14, color: colors.textPrimary)),
                  onTap: () {
                    setState(() => _remindAt = tomorrow9am);
                    _onFieldChanged();
                    Navigator.of(ctx).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.date_range_outlined,
                      color: colors.accentLink, size: 20),
                  title: Text('In 7 days (9:00 AM)',
                      style:
                          TextStyle(fontSize: 14, color: colors.textPrimary)),
                  onTap: () {
                    setState(() => _remindAt = nextWeek9am);
                    _onFieldChanged();
                    Navigator.of(ctx).pop();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.event_available_outlined,
                      color: colors.textSecondary, size: 20),
                  title: Text('Pick custom date & time',
                      style:
                          TextStyle(fontSize: 14, color: colors.textPrimary)),
                  onTap: () async {
                    Navigator.of(ctx).pop();
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
                      if (pickedTime != null && mounted) {
                        setState(() {
                          _remindAt = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                        _onFieldChanged();
                      }
                    }
                  },
                ),
                if (_remindAt != null) ...[
                  Divider(color: colors.surfaceBorder, height: 1),
                  ListTile(
                    leading: Icon(Icons.notifications_off_outlined,
                        color: colors.statusError, size: 20),
                    title: Text('Clear reminder',
                        style: TextStyle(
                            color: colors.statusError,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    onTap: () {
                      setState(() => _remindAt = null);
                      _onFieldChanged();
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ],
            ),
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
    _onFieldChanged();
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    _onFieldChanged();
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
          validatedUrl =
              Validators.validateAndNormalizeUrl(_urlController.text);
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

    final sanitizedContent =
        Validators.sanitizeContent(_contentController.text);

    if (_selectedType == ItemType.image &&
        _pickedFile == null &&
        _existingAttachmentPath == null) {
      setState(() => _errorMessage =
          'An image item requires an attached photo or graphic.');
      return;
    }

    if (_selectedType == ItemType.note &&
        (sanitizedTitle == 'Untitled' &&
            (sanitizedContent == null || sanitizedContent.isEmpty))) {
      setState(() =>
          _errorMessage = 'Please provide either a title or note content.');
      return;
    }

    setState(() => _isSaving = true);
    _draftDebounceTimer?.cancel();

    try {
      final repo = ref.read(itemRepositoryProvider);
      final isNew = widget.itemId == 'new';

      var finalAttachmentPath = _existingAttachmentPath;
      var finalAttachmentName = _attachmentName;
      var finalAttachmentMime = _attachmentMime;

      if (_pickedFile != null &&
          _attachmentName != null &&
          _attachmentMime != null) {
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

      // Clean saved draft on success
      final db = ref.read(databaseProvider);
      await db.deleteDraft(widget.itemId);

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
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save item: $e';
        _isSaving = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final colors = context.stashlyColors;
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.surfaceBorder),
        ),
        title: Text(
          'Discard unsaved changes?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          'You have unsaved changes that will be lost if you leave.',
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Keep Editing',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.statusError,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (discard == true) {
      // Clear draft on explicit user discard
      try {
        final db = ref.read(databaseProvider);
        await db.deleteDraft(widget.itemId);
      } catch (_) {}
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.itemId == 'new';
    final colors = context.stashlyColors;

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: colors.surfaceBackground,
        appBar: AppBar(
          title: Text(
            isNew ? 'New Entry' : 'Edit Entry',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: colors.textPrimary,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accentPrimary,
                  foregroundColor: colors.surfaceBackground,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.surfaceBackground,
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 16),
                label: Text(
                  _isSaving ? 'Saving...' : (isNew ? 'Save' : 'Update'),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            children: [
              // Error banner
              if (_errorMessage != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.statusWarningContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.onStatusWarningContainer
                          .withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: colors.onStatusWarningContainer,
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: colors.onStatusWarningContainer,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _errorMessage = null),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: colors.onStatusWarningContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Content-type pill selector
              _buildTypeSelector(colors),
              const SizedBox(height: 16),

              // Notebook writing surface
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.surfaceBorder, width: 0.8),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field (Prominent, clean, unbordered)
                    TextField(
                      controller: _titleController,
                      maxLength: 200,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: colors.textPrimary,
                        height: 1.3,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Entry Title',
                        hintStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colors.textTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Divider(color: colors.surfaceBorder, height: 1),
                    const SizedBox(height: 12),

                    // URL field if Link or Note
                    if (_selectedType == ItemType.link ||
                        _selectedType == ItemType.note) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.link_rounded,
                            size: 18,
                            color: _selectedType == ItemType.link
                                ? colors.accentLink
                                : colors.textTertiary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _urlController,
                              maxLength: 2048,
                              keyboardType: TextInputType.url,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontFamily: 'monospace',
                                color: colors.accentLink,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                filled: false,
                                counterText: '',
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                hintText: _selectedType == ItemType.link
                                    ? 'https://example.com (Required)'
                                    : 'https://example.com (Optional reference link)',
                                hintStyle: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  color: colors.textTertiary,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(color: colors.surfaceBorder, height: 1),
                      const SizedBox(height: 12),
                    ],

                    // Writing body
                    TextField(
                      controller: _contentController,
                      maxLength: 20000,
                      maxLines: null,
                      minLines: 8,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w400,
                        height: 1.55,
                        color: colors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        hintText: _selectedType == ItemType.link
                            ? 'Notes or excerpts about this link...'
                            : (_selectedType == ItemType.image
                                ? 'Image description or notes...'
                                : 'Start writing thoughts, markdown notes, code snippets...'),
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: colors.textTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Tactical Utility Bar: Attachment + Reminder
              _buildUtilityPanel(colors),
              const SizedBox(height: 14),

              // Tag Manager
              _buildTagSection(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(StashlyColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.surfaceBorder, width: 0.8),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          _buildTypeOption(ItemType.note, 'Note', Icons.description_outlined,
              colors.accentNote, colors),
          _buildTypeOption(ItemType.link, 'Link', Icons.link_rounded,
              colors.accentLink, colors),
          _buildTypeOption(ItemType.image, 'Image', Icons.image_outlined,
              colors.accentImage, colors),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    ItemType type,
    String label,
    IconData icon,
    Color accentColor,
    StashlyColors colors,
  ) {
    final isSelected = _selectedType == type;

    return Expanded(
      child: Material(
        color: isSelected ? colors.surfaceSubtle : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: () {
            setState(() {
              _selectedType = type;
            });
            _onFieldChanged();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected ? accentColor : colors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color:
                        isSelected ? colors.textPrimary : colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUtilityPanel(StashlyColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.surfaceBorder, width: 0.8),
      ),
      child: Column(
        children: [
          // Reminder row
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: _showReminderPicker,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    _remindAt != null
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    size: 18,
                    color: _remindAt != null
                        ? colors.accentPrimary
                        : colors.textTertiary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _remindAt != null
                              ? 'Resurface: ${DateFormat.yMMMd().add_jm().format(_remindAt!)}'
                              : 'Resurface Later',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: _remindAt != null
                                ? colors.accentPrimary
                                : colors.textPrimary,
                          ),
                        ),
                        Text(
                          _remindAt != null
                              ? 'Tap to adjust or remove'
                              : 'Schedule a notification to revisit this item',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_remindAt != null)
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          size: 16, color: colors.textSecondary),
                      onPressed: () {
                        setState(() => _remindAt = null);
                        _onFieldChanged();
                      },
                    )
                  else
                    Icon(Icons.chevron_right_rounded,
                        size: 18, color: colors.textTertiary),
                ],
              ),
            ),
          ),
          Divider(color: colors.surfaceBorder, height: 1),

          // Attachment row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_attachmentName != null || _pickedFile != null) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _attachmentMime == 'application/pdf'
                              ? Icons.picture_as_pdf_outlined
                              : Icons.image_outlined,
                          size: 16,
                          color: colors.accentLink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _attachmentName ?? _pickedFile!.path.split('/').last,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            size: 16, color: colors.textSecondary),
                        onPressed: () {
                          setState(() {
                            _pickedFile = null;
                            _attachmentName = null;
                            _attachmentMime = null;
                            _existingAttachmentPath = null;
                          });
                          _onFieldChanged();
                        },
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      Icon(Icons.attach_file_rounded,
                          size: 18, color: colors.textTertiary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Attachment',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: const Size(0, 32),
                        ),
                        onPressed: _pickImage,
                        icon: Icon(Icons.photo_outlined,
                            size: 15, color: colors.accentPrimary),
                        label: Text('Photo',
                            style: TextStyle(
                                fontSize: 12.5, color: colors.accentPrimary)),
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: const Size(0, 32),
                        ),
                        onPressed: _pickPdf,
                        icon: Icon(Icons.picture_as_pdf_outlined,
                            size: 15, color: colors.accentLink),
                        label: Text('PDF',
                            style: TextStyle(
                                fontSize: 12.5, color: colors.accentLink)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagSection(StashlyColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.surfaceBorder, width: 0.8),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tag_rounded, size: 16, color: colors.textTertiary),
              const SizedBox(width: 8),
              Text(
                'Tags',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${_tags.length}/20',
                style: TextStyle(fontSize: 11, color: colors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagInputController,
                  style: TextStyle(fontSize: 13, color: colors.textPrimary),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    hintText: 'Add a tag (e.g. design, reading)',
                    hintStyle:
                        TextStyle(fontSize: 12.5, color: colors.textTertiary),
                  ),
                  onSubmitted: (val) => _addTag(val),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.surfaceSubtle,
                  foregroundColor: colors.textPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: colors.surfaceBorder, width: 0.8),
                  ),
                ),
                onPressed: () => _addTag(_tagInputController.text),
                child: const Text('Add',
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _tags.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.surfaceBorder, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#$tag',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeTag(tag),
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
