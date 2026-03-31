import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../services/app_state.dart';
import '../../models/user_model.dart';
import '../../screens/main_shell.dart';
//

class AdminLoginScreen extends StatefulWidget {
  final AppState appState;

  const AdminLoginScreen({super.key, required this.appState});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {

  @override
  void initState() {
    super.initState();

    // Simulate loading then login
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {

        //  SET ADMIN USER (VERY IMPORTANT)
        widget.appState.manualLogin(
          UserModel(
            id: "admin_1",
            name: "Admin",
            email: "admin@garage.com",
            phone: "0000000000",
            role: UserRole.admin,
          ),
        );

        //  NAVIGATE TO MAIN SHELL (NOT DIRECT DASHBOARD)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainShell(appState: widget.appState),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 👑 Admin Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '👑',
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Title
            const Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Smart Garage Gujarat',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 48),

            // Loader
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),

            const SizedBox(height: 24),

            const Text(
              'Logging in as Admin...',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}