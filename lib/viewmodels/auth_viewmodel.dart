/**
 * Student Numbers: 222093753, 223005951, 221045356, 221032445, 223082890,
 * Student Names  : DM Skitla, KL Boisa, TD Mokoena, KD Hlokoane, SD Tshabalala,
 * Question: auth_viewmodel.dart - Authentication ViewModel (MVVM Pattern + Provider)
 *           Handles: Sign In, Sign Up, Sign Out, Password Reset, Role Detection
 */

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ──────────────────────────────────────────────────────────────
  bool    get isLoading      => _isLoading;
  String? get errorMessage   => _errorMessage;
  bool    get isLoggedIn     => _supabase.auth.currentSession != null;
  String? get currentUserId  => _supabase.auth.currentUser?.id;
  String? get currentUserEmail => _supabase.auth.currentUser?.email;

  /// Admin users are identified by { "role": "admin" } in their user_metadata.
  /// Set this in: Supabase Dashboard → Authentication → Users → Edit → User Metadata
  bool get isAdmin {
    final meta = _supabase.auth.currentUser?.userMetadata;
    return meta != null && meta['role'] == 'admin';
  }

  // ── Sign Up ──────────────────────────────────────────────────────────────
  Future<bool> signUp(String email, String password) async {
    _setLoading(true);
    try {
      final res = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );
      if (res.user == null) {
        _errorMessage = 'Sign up failed. Please try again.';
        return false;
      }
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'An unexpected error occurred.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Sign In ──────────────────────────────────────────────────────────────
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (res.user == null) {
        _errorMessage = 'Invalid email or password.';
        return false;
      }
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'An unexpected error occurred.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }

  // ── Password Reset ───────────────────────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = value ? null : _errorMessage;
    notifyListeners();
  }
}
