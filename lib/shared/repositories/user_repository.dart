import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

/// Repository untuk mengelola data user/profiles
class UserRepository {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Get users by role
  static Future<List<UserProfile>> getUsersByRole(String roleName) async {
    try {
      print('🔍 Fetching users with role: $roleName');

      // Try to get the role ID with case-insensitive search
      final roleResponse = await _supabase
          .from('roles')
          .select('id')
          .ilike('name', roleName)
          .maybeSingle();

      print('📋 Role response: $roleResponse');

      // If role not found, return empty list instead of throwing error
      if (roleResponse == null) {
        print('❌ Role "$roleName" not found in database');
        return [];
      }

      final roleId = roleResponse['id'] as int;
      print('✅ Found role ID: $roleId');

      // Then, get users with that role
      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('role_id', roleId)
          .eq('is_active', true)
          .order('full_name', ascending: true);

      print('👥 Found ${(response as List).length} users with role $roleName');

      return (response as List)
          .map((json) => UserProfile.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error getting users by role: $e');
      // Return empty list instead of throwing to prevent app crash
      return [];
    }
  }

  /// Get user by ID
  static Future<UserProfile?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Get all active drivers
  static Future<List<UserProfile>> getActiveDrivers() async {
    return getUsersByRole('driver');
  }

  /// Get all active mitra
  static Future<List<UserProfile>> getActiveMitra() async {
    return getUsersByRole('mitra');
  }

  /// Update user profile
  static Future<UserProfile> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? province,
    String? postalCode,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (city != null) updateData['city'] = city;
      if (province != null) updateData['province'] = province;
      if (postalCode != null) updateData['postal_code'] = postalCode;

      final response = await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
