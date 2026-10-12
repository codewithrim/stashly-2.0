import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors.dart';

class AttachmentMetadata {
  final String path;
  final String name;
  final String mime;
  final int sizeBytes;

  const AttachmentMetadata({
    required this.path,
    required this.name,
    required this.mime,
    required this.sizeBytes,
  });
}

class AttachmentService {
  final SupabaseClient _supabase;
  static const int maxSizeBytes = 10 * 1024 * 1024; // 10 MB limit
  static const allowedMimes = {
    'image/jpeg',
    'image/png',
    'image/webp',
    'application/pdf',
  };

  AttachmentService(this._supabase);

  /// Sanitizes filenames: strip separators and limit characters
  static String sanitizeFilename(String filename) {
    var clean = filename.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    if (clean.length > 100) {
      final extIndex = clean.lastIndexOf('.');
      if (extIndex != -1 && extIndex > clean.length - 10) {
        final ext = clean.substring(extIndex);
        clean = '${clean.substring(0, 90)}$ext';
      } else {
        clean = clean.substring(0, 100);
      }
    }
    return clean;
  }

  /// Upload file to the private Supabase attachments bucket
  /// Path convention: <uid>/<item_id>/<sanitized_filename>
  Future<AttachmentMetadata> uploadAttachment({
    required String itemId,
    required File file,
    required String rawFilename,
    required String mimeType,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException('Must be authenticated to upload attachments.');
    }

    // 1. Validation checks
    final size = await file.length();
    if (size > maxSizeBytes) {
      throw const ValidationException('Attachment must not exceed 10 MB.');
    }

    if (!allowedMimes.contains(mimeType.toLowerCase())) {
      throw const ValidationException('Unsupported file format. Allowed: JPEG, PNG, WEBP, PDF.');
    }

    final sanitized = sanitizeFilename(rawFilename);
    final storagePath = '${user.id}/$itemId/$sanitized';

    try {
      await _supabase.storage.from('attachments').upload(
            storagePath,
            file,
            fileOptions: FileOptions(
              contentType: mimeType,
              upsert: true,
            ),
          );

      return AttachmentMetadata(
        path: storagePath,
        name: sanitized,
        mime: mimeType,
        sizeBytes: size,
      );
    } catch (e) {
      throw StorageException('Upload failed: $e');
    }
  }

  /// Generate a short-lived signed URL (60 minutes) for safe access
  Future<String> getSignedUrl(String storagePath) async {
    try {
      final signedUrl = await _supabase.storage.from('attachments').createSignedUrl(
            storagePath,
            3600, // 60 minutes
          );
      return signedUrl;
    } catch (e) {
      throw StorageException('Could not generate secure link for attachment: $e');
    }
  }

  /// Remove attachment object from storage
  Future<void> deleteAttachment(String storagePath) async {
    try {
      await _supabase.storage.from('attachments').remove([storagePath]);
    } catch (_) {
      // Non-blocking cleanup
    }
  }
}
