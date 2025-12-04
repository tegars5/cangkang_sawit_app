import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../../core/services/supabase_service.dart';

/// Repository untuk mengelola operasi Authentication
class AuthRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Sign up user baru dengan email dan password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String namaLengkap,
    required int roleId,
    String? telepon,
  }) async {
    try {
      // 1. Daftar user di Supabase Auth
      final response = await _supabaseService.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // 2. Buat profile user di database
        await _supabaseService.client.from('profiles').insert({
          'user_id': response.user!.id,
          'nama_lengkap': namaLengkap,
          'role_id': roleId,
          'telepon': telepon,
        });
      }

      return response;
    } catch (e) {
      throw Exception('Gagal mendaftar: $e');
    }
  }

  /// Sign in user dengan email dan password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Gagal login: $e');
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _supabaseService.auth.signOut();
    } catch (e) {
      throw Exception('Gagal logout: $e');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _supabaseService.currentUser;
  }

  /// Get user profile dengan relasi role
  Future<UserProfile?> getUserProfile() async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) return null;

      final response = await _supabaseService.client
          .from('profiles')
          .select('*, roles(*)')
          .eq('user_id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil profile user: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String namaLengkap,
    String? telepon,
  }) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) throw Exception('User tidak login');

      await _supabaseService.client
          .from('profiles')
          .update({'nama_lengkap': namaLengkap, 'telepon': telepon})
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Gagal update profile: $e');
    }
  }

  /// Change password
  Future<void> changePassword({required String newPassword}) async {
    try {
      await _supabaseService.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Gagal ubah password: $e');
    }
  }

  /// Reset password dengan email
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabaseService.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Gagal reset password: $e');
    }
  }

  /// Stream untuk listen perubahan auth state
  Stream<AuthState> get authStateStream =>
      _supabaseService.auth.onAuthStateChange;

  /// Cek apakah user sudah login
  bool get isLoggedIn => _supabaseService.isLoggedIn;
}
