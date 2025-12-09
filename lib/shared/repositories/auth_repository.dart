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
      print('🔍 DEBUG SignUp: Starting sign up for $email');

      // 1. Daftar user di Supabase Auth
      print('🔍 DEBUG SignUp: Calling auth.signUp...');
      final response = await _supabaseService.auth.signUp(
        email: email,
        password: password,
      );

      print(
        '🔍 DEBUG SignUp: Auth response received, user ID: ${response.user?.id}',
      );

      if (response.user != null) {
        // 2. Check if profile already exists (prevent duplicate)
        print('🔍 DEBUG SignUp: Checking existing profile...');
        final existingProfile = await _supabaseService.client
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .maybeSingle();

        print(
          '🔍 DEBUG SignUp: Existing profile: ${existingProfile != null ? "found" : "not found"}',
        );

        if (existingProfile == null) {
          // 3. Insert profile with all required fields and defaults
          print('🔍 DEBUG SignUp: Inserting new profile...');
          print(
            '🔍 DEBUG SignUp: Data: id=${response.user!.id}, email=$email, name=$namaLengkap, roleId=$roleId',
          );

          await _supabaseService.client.from('profiles').insert({
            'id': response.user!.id,
            'email': email,
            'full_name': namaLengkap.isNotEmpty ? namaLengkap : 'User',
            'role_id': roleId,
            'phone': telepon ?? '',
            'address': '',
            'is_active': true,
            'created_at': DateTime.now().toIso8601String(),
          });

          print('✅ DEBUG SignUp: Profile inserted successfully');
        } else {
          // Profile already exists, update it
          print('🔍 DEBUG SignUp: Updating existing profile...');
          await _supabaseService.client
              .from('profiles')
              .update({
                'email': email,
                'full_name': namaLengkap.isNotEmpty ? namaLengkap : 'User',
                'role_id': roleId,
                'phone': telepon ?? '',
              })
              .eq('id', response.user!.id);
          print('✅ DEBUG SignUp: Profile updated successfully');
        }
      }

      print('✅ DEBUG SignUp: Sign up completed successfully');
      return Success(response);
    } on supabase.AuthException catch (e) {
      print('❌ DEBUG SignUp: AuthException - ${e.message}');
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
      print(
        '❌ DEBUG SignUp: PostgrestException - code: ${e.code}, message: ${e.message}',
      );
      // Handle duplicate key error specifically
      if (e.code == '23505') {
        return Failure(
          DatabaseException(
            message: 'Email sudah terdaftar. Silakan gunakan email lain.',
            code: e.code,
            details: e.message,
          ),
        );
      }
      return Failure(DatabaseException.queryFailed(e.message));
    } on SocketException {
      print('❌ DEBUG SignUp: SocketException - No connection');
      return Failure(NetworkException.noConnection());
    } catch (e, stackTrace) {
      print('❌ DEBUG SignUp: Unknown error - $e');
      print('❌ DEBUG SignUp: Stack trace - $stackTrace');
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

      print('🔍 Getting profile for user ID: $userId');

      final response = await _supabaseService.client
          .from('profiles')
          .select('''
            id,
            email,
            full_name,
            role_id,
            phone,
            address,
            is_active,
            avatar_url,
            city,
            province,
            postal_code,
            driver_license,
            vehicle_type,
            vehicle_plate,
            company_name,
            job_title,
            latitude,
            longitude,
            created_at,
            updated_at,
            roles (
              id,
              name,
              created_at
            )
          ''')
          .eq('id', userId)
          .single();

      print('✅ Profile query successful');
      print('📊 Response: $response');

      final profile = UserProfile.fromJson(response);

      print('✅ Profile parsed: ${profile.email}, role_id: ${profile.roleId}');

      return Success(profile);
    } on PostgrestException catch (e) {
      print('❌ PostgrestException: ${e.code} - ${e.message}');
      if (e.code == 'PGRST116') {
        return Failure(DatabaseException.recordNotFound('Profil'));
      } else {
        return Failure(DatabaseException.queryFailed(e.message));
      }
    } on SocketException {
      print('❌ SocketException: No internet connection');
      return Failure(NetworkException.noConnection());
    } catch (e) {
      print('❌ Unexpected error: $e');
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

  /// Update user profile
  Future<Result<void>> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _supabaseService.client
          .from('profiles')
          .update(updates)
          .eq('id', userId);
      return const Success(null);
    } on PostgrestException catch (e) {
      return Failure(DatabaseException.queryFailed(e.message));
    } on SocketException {
      return Failure(NetworkException.noConnection());
    } catch (e) {
      return Failure(UnknownException.generic(e));
    }
  }
}
