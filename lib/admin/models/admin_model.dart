// File: lib/admin/models/admin_model.dart
class AdminModel {
  final String id;
  final String email;
  final String name;
  final String role; // super_admin, moderator, viewer
  final String? phone;
  final DateTime? lastLogin;
  final bool isActive;

  AdminModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.lastLogin,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phone': phone,
      'lastLogin': lastLogin,
      'isActive': isActive,
    };
  }

  factory AdminModel.fromMap(Map<String, dynamic> map, String id) {
    return AdminModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'moderator',
      phone: map['phone'],
      lastLogin: map['lastLogin']?.toDate(),
      isActive: map['isActive'] ?? true,
    );
  }
}

enum AdminRole {
  superAdmin,
  moderator,
  viewer,
}

extension AdminRoleExtension on AdminRole {
  String get value {
    switch (this) {
      case AdminRole.superAdmin:
        return 'super_admin';
      case AdminRole.moderator:
        return 'moderator';
      case AdminRole.viewer:
        return 'viewer';
    }
  }

  String get displayName {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.moderator:
        return 'Moderator';
      case AdminRole.viewer:
        return 'Viewer';
    }
  }

  static AdminRole fromString(String role) {
    switch (role) {
      case 'super_admin':
        return AdminRole.superAdmin;
      case 'moderator':
        return AdminRole.moderator;
      case 'viewer':
        return AdminRole.viewer;
      default:
        return AdminRole.viewer;
    }
  }
}