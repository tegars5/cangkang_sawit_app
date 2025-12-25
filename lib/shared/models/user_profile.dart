import '../../features/auth/domain/entities/user.dart';

/// Re-export User entity as UserProfile for backward compatibility
/// This allows the domain layer to use UserProfile while the actual entity is User
typedef UserProfile = User;
