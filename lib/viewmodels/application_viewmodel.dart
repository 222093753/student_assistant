/**
* Student Numbers: 222093753, 223005951, 221045356, 221032445, 223082890,
 * Student Names  : DM Skitla, KL Boisa, TD Mokoena, KD Hlokoane, SD Tshabalala,
 * Question: application_viewmodel.dart - MVVM ViewModel for SA Applications
 *           Implements full CRUD: Create, Read, Update, Delete with Supabase
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sa_application.dart';
import '../services/storage_service.dart';

class ApplicationViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storage  = StorageService();

  List<SAApplication> _myApplications  = [];
  List<SAApplication> _allApplications = [];
  bool   _isLoading   = false;
  bool   _isUploading = false;
  String? _errorMessage;

  // ── Getters ──────────────────────────────────────────────────────────────
  List<SAApplication> get myApplications  => _myApplications;
  List<SAApplication> get allApplications => _allApplications;
  bool    get isLoading    => _isLoading;
  bool    get isUploading  => _isUploading;
  String? get errorMessage => _errorMessage;
  bool    get hasApplication => _myApplications.isNotEmpty;

  // ════════════════════════════════════════════════════════════════════════
  // CREATE
  // ════════════════════════════════════════════════════════════════════════
  Future<bool> submitApplication({
    required String studentName,
    required String studentNumber,
    required int    yearOfStudy,
    required String module1Level,
    required String module1Name,
    String?  module2Level,
    String?  module2Name,
    required bool   meetsRequirements,
    File?    documentFile,
  }) async {
    _setLoading(true);
    try {
      final uid = _supabase.auth.currentUser!.id;

      // Enforce one application per student
      final existing = await _supabase
          .from('sa_applications')
          .select('id')
          .eq('user_id', uid);
      if ((existing as List).isNotEmpty) {
        _errorMessage = 'You have already submitted an application.';
        return false;
      }

      // Insert base record
      final rows = await _supabase.from('sa_applications').insert({
        'user_id':            uid,
        'student_name':       studentName,
        'student_number':     studentNumber,
        'year_of_study':      yearOfStudy,
        'module1_level':      module1Level,
        'module1_name':       module1Name,
        if (module2Level != null && module2Level.isNotEmpty)
          'module2_level':    module2Level,
        if (module2Name  != null && module2Name.isNotEmpty)
          'module2_name':     module2Name,
        'meets_requirements': meetsRequirements,
        'status':             'pending',
      }).select();

      if ((rows as List).isEmpty) return false;
      final newApp = SAApplication.fromJson(rows.first);

      // Upload supporting document
      String? docUrl;
      if (documentFile != null) {
        _isUploading = true;
        notifyListeners();
        docUrl = await _storage.uploadDocument(newApp.id, documentFile);
        if (docUrl != null) {
          await _supabase
              .from('sa_applications')
              .update({'document_url': docUrl}).eq('id', newApp.id);
        }
        _isUploading = false;
      }

      _myApplications.insert(0, newApp.copyWith(documentUrl: docUrl));
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // READ – Student (own applications only, enforced by RLS)
  // ════════════════════════════════════════════════════════════════════════
  Future<void> fetchMyApplications() async {
    _setLoading(true);
    try {
      final uid = _supabase.auth.currentUser?.id;
      if (uid == null) return;

      final rows = await _supabase
          .from('sa_applications')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);

      _myApplications =
          (rows as List).map((r) => SAApplication.fromJson(r)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // READ – Admin (all applications)
  // ════════════════════════════════════════════════════════════════════════
  Future<void> fetchAllApplications({String? statusFilter}) async {
    _setLoading(true);
    try {
      final rows = await _supabase
          .from('sa_applications')
          .select()
          .order('created_at', ascending: false);

      _allApplications =
          (rows as List).map((r) => SAApplication.fromJson(r)).toList();

      // Optional client-side status filter
      if (statusFilter != null && statusFilter != 'all') {
        _allApplications =
            _allApplications.where((a) => a.status == statusFilter).toList();
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // UPDATE – Student edits their own pending application
  // ════════════════════════════════════════════════════════════════════════
  Future<bool> updateApplication({
    required String id,
    required String studentName,
    required String studentNumber,
    required int    yearOfStudy,
    required String module1Level,
    required String module1Name,
    String?  module2Level,
    String?  module2Name,
    required bool   meetsRequirements,
    File?    newDocumentFile,
  }) async {
    _setLoading(true);
    try {
      final old = getMyApplicationById(id);
      String? docUrl = old?.documentUrl;

      // Replace document if a new file was picked
      if (newDocumentFile != null) {
        _isUploading = true;
        notifyListeners();
        if (old?.documentUrl != null) {
          await _storage.deleteDocument(old!.documentUrl!);
        }
        docUrl = await _storage.uploadDocument(id, newDocumentFile);
        _isUploading = false;
      }

      await _supabase.from('sa_applications').update({
        'student_name':       studentName,
        'student_number':     studentNumber,
        'year_of_study':      yearOfStudy,
        'module1_level':      module1Level,
        'module1_name':       module1Name,
        'module2_level':      (module2Level != null && module2Level.isNotEmpty)
                                ? module2Level : null,
        'module2_name':       (module2Name  != null && module2Name.isNotEmpty)
                                ? module2Name : null,
        'meets_requirements': meetsRequirements,
        if (docUrl != null) 'document_url': docUrl,
        'updated_at':         DateTime.now().toIso8601String(),
      }).eq('id', id);

      // Update local list
      final idx = _myApplications.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _myApplications[idx] = _myApplications[idx].copyWith(
          studentName:       studentName,
          studentNumber:     studentNumber,
          yearOfStudy:       yearOfStudy,
          module1Level:      module1Level,
          module1Name:       module1Name,
          module2Level:      module2Level,
          module2Name:       module2Name,
          meetsRequirements: meetsRequirements,
          documentUrl:       docUrl,
          updatedAt:         DateTime.now(),
        );
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // UPDATE – Admin approves or rejects an application
  // ════════════════════════════════════════════════════════════════════════
  Future<bool> updateStatus({
    required String id,
    required String status,   // 'approved' | 'rejected'
    String? adminComment,
  }) async {
    _setLoading(true);
    try {
      await _supabase.from('sa_applications').update({
        'status':        status,
        'admin_comment': adminComment,
        'updated_at':    DateTime.now().toIso8601String(),
      }).eq('id', id);

      final idx = _allApplications.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _allApplications[idx] = _allApplications[idx].copyWith(
          status:       status,
          adminComment: adminComment,
          updatedAt:    DateTime.now(),
        );
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // DELETE – Student deletes pending app OR Admin removes any app
  // ════════════════════════════════════════════════════════════════════════
  Future<bool> deleteApplication(String id) async {
    _setLoading(true);
    try {
      // Delete linked document from storage first
      final app = getMyApplicationById(id) ?? getAdminApplicationById(id);
      if (app?.documentUrl != null) {
        await _storage.deleteDocument(app!.documentUrl!);
      }

      await _supabase.from('sa_applications').delete().eq('id', id);

      _myApplications.removeWhere((a) => a.id == id);
      _allApplications.removeWhere((a) => a.id == id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  SAApplication? getMyApplicationById(String id) {
    try { return _myApplications.firstWhere((a) => a.id == id); }
    catch (_) { return null; }
  }

  SAApplication? getAdminApplicationById(String id) {
    try { return _allApplications.firstWhere((a) => a.id == id); }
    catch (_) { return null; }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    if (v) _errorMessage = null;
    notifyListeners();
  }
}
