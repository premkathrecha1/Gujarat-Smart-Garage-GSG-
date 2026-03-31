// File: lib/admin/services/admin_auth.dart
class AdminAuth {
  // Fixed admin credentials
  static const String adminEmail = 'admin@smartgarage.com';
  static const String adminPassword = 'Admin@123';
  
  // Optional: Add multiple admin accounts
  static const Map<String, String> adminAccounts = {
    'admin@smartgarage.com': 'Admin@123',
    'superadmin@smartgarage.com': 'SuperAdmin@123',
    'moderator@smartgarage.com': 'Moderator@123',
  };
  
  // Check if credentials are valid admin credentials
  static bool isAdminLogin(String email, String password) {
    return adminAccounts.containsKey(email) && adminAccounts[email] == password;
  }
  
  // Check if email is admin email
  static bool isAdminEmail(String email) {
    return adminAccounts.containsKey(email);
  }
  
  // Get admin role based on email
  static String getAdminRole(String email) {
    if (email == 'admin@smartgarage.com') return 'Super Admin';
    if (email == 'superadmin@smartgarage.com') return 'Super Admin';
    if (email == 'moderator@smartgarage.com') return 'Moderator';
    return 'Admin';
  }
}