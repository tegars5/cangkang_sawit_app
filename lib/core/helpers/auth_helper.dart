import 'package:flutter/material.dart';
import '../../widgets/common/logout_button.dart';

/// Helper class for authentication-related UI components
///
/// This class provides reusable authentication widgets following clean code principles.
/// All business logic is delegated to controllers, this class only handles UI.
class AuthHelper {
  /// Build a logout icon button for use in AppBar
  ///
  /// This is a convenience method that creates a LogoutButton.icon()
  ///
  /// Example:
  /// ```dart
  /// AppBar(
  ///   actions: [
  ///     AuthHelper.buildLogoutButton(context),
  ///   ],
  /// )
  /// ```
  static Widget buildLogoutButton(BuildContext context) {
    return LogoutButton.icon();
  }

  /// Build a full-width logout button for use in settings/profile pages
  ///
  /// Example:
  /// ```dart
  /// AuthHelper.buildLogoutButtonFullWidth(context)
  /// ```
  static Widget buildLogoutButtonFullWidth(BuildContext context) {
    return LogoutButton.fullWidth();
  }
}
