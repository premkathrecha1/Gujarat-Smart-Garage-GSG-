// lib/screens/login_screen.dart
// Full Firebase Auth — real login + register with error handling
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/app_state.dart';
import '../widgets/role_card.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'car_registration_screen.dart';
import 'main_shell.dart';
import '../admin/screens/admin_dashboard_screen.dart';
import '../admin/services/admin_auth.dart';

class LoginScreen extends StatefulWidget {
  final AppState appState;
  const LoginScreen({super.key, required this.appState});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _obscureLogin = true;
  bool _obscureReg = true;

  // Login
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  UserRole _loginRole = UserRole.carOwner;

  // Register
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regGarageCtrl = TextEditingController();
  UserRole _regRole = UserRole.carOwner;
  String? _regCity;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regPassCtrl.dispose();
    _regGarageCtrl.dispose();
    super.dispose();
  }

  // ── Navigation helper ─────────────────────────────────────────────────────
  void _navigateAfterLogin(UserModel user) {
    if (!mounted) return;
    if (user.isCarOwner) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => CarRegistrationScreen(
            appState: widget.appState,
            user: user,
            isNewUser: true,
          ),
        ),
        (r) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MainShell(appState: widget.appState)),
        (r) => false,
      );
    }
  }

  void _goToShell() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainShell(appState: widget.appState)),
      (r) => false,
    );
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<void> _doLogin() async {
    final email = _loginEmailCtrl.text.trim();
    final pass = _loginPassCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      showSnackBar(context, 'Please enter email and password', isError: true);
      return;
    }

    // Admin bypass
    if (AdminAuth.isAdminLogin(email, pass)) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        (r) => false,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.appState.loginWithFirebase(email: email, password: pass);
      final user = widget.appState.user!;
      // Returning car owner → go directly to shell (cars load via stream)
      _goToShell();
    } catch (e) {
      if (mounted) showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<void> _doRegister() async {
    final name = _regNameCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final phone = _regPhoneCtrl.text.trim();
    final pass = _regPassCtrl.text;
    final garage = _regGarageCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      showSnackBar(context, 'Name, email and password are required', isError: true);
      return;
    }
    if (_regRole == UserRole.garageOwner && garage.isEmpty) {
      showSnackBar(context, 'Please enter your garage name', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.appState.registerWithFirebase(
        email: email,
        password: pass,
        name: name,
        phone: phone,
        role: _regRole,
        garageName: _regRole == UserRole.garageOwner ? garage : null,
        city: _regCity ?? 'Ahmedabad',
      );
      final user = widget.appState.user!;
      _navigateAfterLogin(user);
    } catch (e) {
      if (mounted) showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Quick logins (dev only) ───────────────────────────────────────────────
  void _quickAdmin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      (r) => false,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 240,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppColors.primaryDark, AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12)]),
                        child: const Center(child: Text('🔧', style: TextStyle(fontSize: 24))),
                      ),
                      const SizedBox(width: 12),
                      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Smart Garage', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                        Text('Gujarat', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ]),
                      const Spacer(),
                      // Admin shortcut
                      GestureDetector(
                        onTap: _quickAdmin,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Text('👑 Admin', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 32, spreadRadius: 2)],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: Container(
                            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(14)),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: Colors.white,
                              unselectedLabelColor: AppColors.textSecondary,
                              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              dividerColor: Colors.transparent,
                              tabs: const [Tab(text: 'Login'), Tab(text: 'Register')],
                            ),
                          ),
                        ),
                        Expanded(child: TabBarView(controller: _tabController, children: [_buildLoginTab(), _buildRegisterTab()])),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Welcome Back! 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Sign in to your account', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        _label('SELECT ROLE'),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: RoleCard(icon: '🚗', label: 'Car Owner', isSelected: _loginRole == UserRole.carOwner, onTap: () => setState(() => _loginRole = UserRole.carOwner))),
          const SizedBox(width: 12),
          Expanded(child: RoleCard(icon: '🔧', label: 'Garage Owner', isSelected: _loginRole == UserRole.garageOwner, onTap: () => setState(() => _loginRole = UserRole.garageOwner))),
        ]),
        const SizedBox(height: 20),
        _label('Email'),
        TextField(controller: _loginEmailCtrl, keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'your@email.com', prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.primary, size: 20))),
        const SizedBox(height: 14),
        _label('Password'),
        TextField(controller: _loginPassCtrl, obscureText: _obscureLogin,
          decoration: InputDecoration(hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
            suffixIcon: IconButton(icon: Icon(_obscureLogin ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary, size: 20),
              onPressed: () => setState(() => _obscureLogin = !_obscureLogin)))),
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Forgot Password?', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)))),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _doLogin,
            child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Login →'),
          )),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderColor)),
          child: const Row(children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
            SizedBox(width: 8),
            Expanded(child: Text('Admin: admin@smartgarage.com / Admin@123', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600))),
          ]),
        ),
      ]),
    );
  }

  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Create Account 🙏', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Join thousands of Gujarat car owners', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        _label('SELECT ROLE'),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: RoleCard(icon: '🚗', label: 'Car Owner', isSelected: _regRole == UserRole.carOwner, onTap: () => setState(() => _regRole = UserRole.carOwner))),
          const SizedBox(width: 12),
          Expanded(child: RoleCard(icon: '🔧', label: 'Garage Owner', isSelected: _regRole == UserRole.garageOwner, onTap: () => setState(() => _regRole = UserRole.garageOwner))),
        ]),
        const SizedBox(height: 20),
        _label('Full Name *'),
        TextField(controller: _regNameCtrl, decoration: const InputDecoration(hintText: 'Rajesh Patel', prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20))),
        const SizedBox(height: 14),
        _label('Email *'),
        TextField(controller: _regEmailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'your@email.com', prefixIcon: Icon(Icons.mail_outline_rounded, color: AppColors.primary, size: 20))),
        const SizedBox(height: 14),
        _label('Phone'),
        TextField(controller: _regPhoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '+91 98765 43210', prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary, size: 20))),
        const SizedBox(height: 14),
        _label('City'),
        DropdownButtonFormField<String>(
          value: _regCity,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.location_city_outlined, color: AppColors.primary, size: 20)),
          hint: const Text('Select City'),
          items: AppConstants.gujaratCities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _regCity = v),
        ),
        if (_regRole == UserRole.garageOwner) ...[
          const SizedBox(height: 14),
          _label('Garage Name *'),
          TextField(controller: _regGarageCtrl, decoration: const InputDecoration(hintText: 'Patel Auto Service', prefixIcon: Icon(Icons.store_outlined, color: AppColors.primary, size: 20))),
        ],
        const SizedBox(height: 14),
        _label('Password * (min 6 characters)'),
        TextField(controller: _regPassCtrl, obscureText: _obscureReg,
          decoration: InputDecoration(hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
            suffixIcon: IconButton(icon: Icon(_obscureReg ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary, size: 20),
              onPressed: () => setState(() => _obscureReg = !_obscureReg)))),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _doRegister,
            child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(_regRole == UserRole.carOwner ? 'Next: Add Your Car →' : 'Create Account & Go'),
          )),
      ]),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8)));
}