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

      // Get user profile
      final profileData = await _client
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      return UserProfile.fromJson(profileData);
    } on AuthException catch (e) {
      // Supabase AuthException
      throw AppAuthException(e.message);
    } on PostgrestException catch (e) {
      throw ServerException('Failed to get profile: ${e.message}');
    } catch (e) {
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
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AppAuthException('Registration failed');
      }

      // Create profile
      final profileData = {
        'id': response.user!.id,
        'name': name,
        'email': email,
        'role': role,
        ...?additionalData,
      };

      await _client.from('profiles').insert(profileData);

      return UserProfile.fromJson(profileData);
    } on AuthException catch (e) {
      // Supabase AuthException
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
