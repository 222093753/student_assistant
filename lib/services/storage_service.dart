/**
 * Student Numbers: 222093753, 223005951, 221045356, 221032445, 223082890,
 * Student Names  : DM Skitla, KL Boisa, TD Mokoena, KD Hlokoane, SD Tshabalala,
 * Question: storage_service.dart - Supabase Storage Service (File Upload & Delete)
 */

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Must match the bucket name you created in Supabase Dashboard → Storage
  static const String _bucket = 'sa_documents';

  // ── Upload Document ──────────────────────────────────────────────────────
  /// Uploads a supporting document. Returns public URL on success, null on failure.
  Future<String?> uploadDocument(String applicationId, File file) async {
    try {
      final ext = file.path.split('.').last.toLowerCase();
      final fileName =
          '$applicationId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      await _supabase.storage.from(_bucket).upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final url = _supabase.storage.from(_bucket).getPublicUrl(fileName);
      return url;
    } catch (e) {
      print('StorageService.uploadDocument error: $e');
      return null;
    }
  }

  // ── Delete Document ──────────────────────────────────────────────────────
  /// Deletes a document from storage given its public URL.
  Future<bool> deleteDocument(String publicUrl) async {
    try {
      final uri = Uri.parse(publicUrl);
      final segments = uri.pathSegments;
      // Path after /storage/v1/object/public/<bucket>/...
      final bucketIdx = segments.indexOf(_bucket);
      if (bucketIdx == -1) return false;
      final filePath = segments.sublist(bucketIdx + 1).join('/');
      await _supabase.storage.from(_bucket).remove([filePath]);
      return true;
    } catch (e) {
      print('StorageService.deleteDocument error: $e');
      return false;
    }
  }
}
