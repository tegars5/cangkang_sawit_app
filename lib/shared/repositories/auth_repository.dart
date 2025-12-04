import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart'
    as supabase
    show AuthException;
import '../models/models.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/result.dart';
import '../../core/errors/app_exception.dart';

/// Repository untuk mengelola operasi Authentication
class AuthRepository {
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Sign in user dengan email dan password
  /// Returns Result<AuthResponse> untuk handling yang lebih baik
  Future<Result<AuthResponse>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return Success(response);
    } on supabase.AuthException catch (e) {
      // Handle Supabase auth errors
      if (e.message.toLowerCase().contains('invalid') ||
          e.message.toLowerCase().contains('credentials')) {
        return Failure(AuthException.invalidCredentials());
      } else if (e.message.toLowerCase().contains('not found')) {
        return Failure(AuthException.userNotFound());
      } else {
        return Failure(
          AuthException(
            message: 'Gagal login: ${e.message}',
            code: e.statusCode,
            details: e.message,
          ),
        );
      }
    } on PostgrestException catch (e) {
      return Failure(DatabaseException.queryFailed(e.message));
    } on SocketException {
      return Failure(NetworkException.noConnection());
    } catch (e) {
      return Failure(UnknownException.generic(e));
    }
  }

  /// Sign up user baru dengan email dan password
  Future<Result<AuthResponse>> signUp({
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
        // CRITICAL FIX: Gunakan nama kolom yang sesuai dengan schema database
        await _supabaseService.client.from('profiles').insert({
          'id': response.user!.id, // Primary Key profiles = auth.users.id
          'email': email, // Kolom email wajib (NOT NULL)
          'full_name': namaLengkap, // Kolom di DB adalah 'full_name'
          'role_id': roleId,
          'phone': telepon, // Kolom di DB adalah 'phone'
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      return Success(response);
    } on supabase.AuthException catch (e) {
      if (e.message.toLowerCase().contains('already') ||
          e.message.toLowerCase().contains('exists')) {
        return Failure(AuthException.emailAlreadyExists());
      } else if (e.message.toLowerCase().contains('weak') ||
          e.message.toLowerCase().contains('password')) {
        return Failure(AuthException.weakPassword());
      } else {
        return Failure(
          AuthException(
            message: 'Gagal mendaftar: ${e.message}',
            code: e.statusCode,
            details: e.message,
          ),
        );
      }
    } on PostgrestException catch (e) {
      return Failure(DatabaseException.queryFailed(e.message));
    } on SocketException {
      return Failure(NetworkException.noConnection());
    } catch (e) {
      return Failure(UnknownException.generic(e));
    }
  }

  /// Sign out user
  Future<Result<void>> signOut() async {
    try {
      await _supabaseService.auth.signOut();
      return const Success(null);
    } on supabase.AuthException catch (e) {
      return Failure(
        AuthException(
          message: 'Gagal logout: ${e.message}',
          code: e.statusCode,
          details: e.message,
        ),
      );
    } on SocketException {
      return Failure(NetworkException.noConnection());
    } catch (e) {
      return Failure(UnknownException.generic(e));
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _supabaseService.currentUser;
  }

  /// Get user profile dengan relasi role
  Future<Result<UserProfile>> getUserProfile() async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) {
        return Failure(AuthException.sessionExpired());
      }

      final response = await _supabaseService.client
          .from('profiles')
          .select('*, roles(*)')
          .eq('id', userId) // FIXED: Gunakan 'id' bukan 'user_id'
          .single();

      final profile = UserProfile.fromJson(response);
      return Success(profile);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // No rows returned
        return Failure(DatabaseException.recordNotFound('Profil'));
      } else {
        return Failure(DatabaseException.queryFailed(e.message));
      }
    } on SocketException {
      return Failure(NetworkException.noConnection());
    } catch (e) {
      return Failure(UnknownException.generic(e));
    }
  }

  /// Update user profile
  Future<Result<void>> updateUserProfile({
    required String namaLengkap,
    String? telepon,
  }) async {
    try {
      final userId = _supabaseService.currentUserId;
      if (userId == null) {
        return Failure(AuthException.sessionExpired());
      }

      // FIXED: Gunakan nama kolom yang sesuai schema
      await _supabaseService.client
          .from('profiles')
          .update({
            'full_name': namaLengkap, // Kolom di DB adalah 'full_name'
            'phone': telepon, // Kolom di DB adalah 'phone'
          })
          .eq('id', userId); // Kolom primary key adalah 'id'

      return const Success(null);
    } on PostgrestException catch (e) {
      return Failure(DatabaseException.queryFailed(e.message));
    } on SocketException {
      return Failure(NetworkException.noConnection());
    } catch (e) {
      return Failure(UnknownException.generic(e));
    }
  }

  /// Change password
  Future<Result<void>> changePassword({required String newPassword}) async {
    try {
      await _supabaseService.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return const Success(null);
    } on supabase.AuthException catch (e) {
      if (e.message.toLowerCase().contains('weak')) {
        return Failure(AuthException.weakPassword());
      } else {
        return Failure(
          AuthException(
            message: 'Gagal ubah password: ${e.message}',
            code: e.statusCode,
            details: e.message,
          ),
        );
      }
    } on SocketException {
      return Failure(NetworkException.noConnection());
    } catch (e) {
      return Failure(UnknownException.generic(e));
    }
  }

  /// Reset password dengan email
  Future<Result<void>> resetPassword({required String email}) async {
    try {
      await _supabaseService.auth.resetPasswordForEmail(email);
      return const Success(null);
    } on supabase.AuthException catch (e) {
      return Failure(
        AuthException(
          message: 'Gagal reset password: ${e.message}',
          code: e.statusCode,
          details: e.message,
        ),
      );
    } on SocketException {
      return Failure(NetworkException.noConnection());
    } catch (e) {
      return Failure(UnknownException.generic(e));
    }
  }

  /// Stream untuk listen perubahan auth state
  Stream<AuthState> get authStateStream =>
      _supabaseService.auth.onAuthStateChange;

  /// Cek apakah user sudah login
  bool get isLoggedIn => _supabaseService.isLoggedIn;
}
