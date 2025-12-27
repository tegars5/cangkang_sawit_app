import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../shared/models/models.dart';

/// Remote data source for Auth operations
class AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSource({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Login with email and password
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AppAuthException('Login failed');
      }

      print('🔐 Auth success! User ID: ${response.user!.id}');

      // Get user profile with explicit columns
      try {
        print('📊 Querying profile...');
        final profileData = await _client
            .from('profiles')
            .select(
              'id, email, full_name, role_id, phone, address, is_active, '
              'avatar_url, city, province, postal_code, driver_license, '
              'vehicle_type, vehicle_plate, company_name, job_title, '
              'latitude, longitude, created_at, updated_at',
            )
            .eq('id', response.user!.id)
            .single();

        print('✅ Profile fetched: ${profileData['email']}');
        print('👤 Role ID: ${profileData['role_id']}');

        return UserProfile.fromJson(profileData);
      } on PostgrestException catch (e) {
        print('❌ PostgrestException: ${e.code} - ${e.message}');
        print('📋 Details: ${e.details}');
        throw ServerException('Gagal mengambil profil: ${e.message}');
      } catch (e) {
        print('❌ Unexpected profile error: $e');
        rethrow;
      }
    } on AuthException catch (e) {
      print('❌ AuthException: ${e.message}');
      // Handle specific Supabase auth errors with user-friendly messages
      if (e.message.contains('Invalid login credentials') ||
          e.message.contains('invalid') ||
          e.message.contains('credentials')) {
        throw const AppAuthException('Email atau password salah');
      }
      if (e.message.contains('Email not confirmed')) {
        throw const AppAuthException('Email belum dikonfirmasi');
      }
      throw AppAuthException(e.message);
    } on PostgrestException catch (e) {
      print('❌ PostgrestException (outer): ${e.code} - ${e.message}');
      throw ServerException('Failed to get profile: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error: $e');
      print('Stack trace: ${StackTrace.current}');
      throw AppAuthException('Login failed: $e');
    }
  }

  /// Register new user
  Future<UserProfile> register({
    required String email,
    required String password,
    required String name,
    required String role,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Sign up with metadata for trigger to read
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'role': role, // Trigger will read this
          ...?additionalData,
        },
      );

      if (response.user == null) {
        throw const AppAuthException('Registration failed');
      }

      // Wait a bit for trigger to create profile
      await Future.delayed(const Duration(milliseconds: 500));

      // Fetch the profile created by trigger
      try {
        final profileData = await _client
            .from('profiles')
            .select(
              'id, email, full_name, role_id, phone, address, is_active, '
              'avatar_url, city, province, postal_code, driver_license, '
              'vehicle_type, vehicle_plate, company_name, job_title, '
              'latitude, longitude, created_at, updated_at',
            )
            .eq('id', response.user!.id)
            .single();

        return UserProfile.fromJson(profileData);
      } on PostgrestException catch (e) {
        // Profile not found - trigger might have failed
        if (e.code == 'PGRST116') {
          throw ServerException(
            'Profile creation failed. Please contact support.',
          );
        }
        throw ServerException('Failed to get profile: ${e.message}');
      }
    } on AuthException catch (e) {
      // Handle specific Supabase auth errors
      if (e.message.contains('already registered') ||
          e.message.contains('already exists')) {
        throw const AppAuthException('Email sudah terdaftar');
      }
      if (e.message.contains('Password')) {
        throw const AppAuthException('Password terlalu lemah');
      }
      throw AppAuthException(e.message);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to create profile: ${e.message}');
    } catch (e) {
      throw AppAuthException('Registration failed: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AppAuthException('Logout failed: $e');
    }
  }

  /// Get current user
  Future<UserProfile?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      'id, email, full_name, role_id, phone, address, is_active, '
          'avatar_url, city, province, postal_code, driver_license, '
          'vehicle_type, vehicle_plate, company_name, job_title, '
          'latitude, longitude, created_at, updated_at';
      final profileData = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserProfile.fromJson(profileData);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get profile: ${e.message}');
    } catch (e) {
      return null;
    }
  }

  /// Update profile
  Future<UserProfile> updateProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _client.from('profiles').update(updates).eq('id', userId);

      final profileData = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(profileData);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to update profile: ${e.message}');
    } catch (e) {
      throw ServerException('Update failed: $e');
    }
  }
}
