// lib/admin/screens/admin_dashboard_screen.dart
// Full admin panel — all data from Firestore streams
// Users: list, search, filter, delete, toggle active
// Cars: list, search, delete
// Work Posts: list, search, filter, delete
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../models/user_model.dart';
import '../../models/car_model.dart';
import '../../models/work_post.dart';
import '../../services/firebase_service.dart';
import '../../../screens/login_screen.dart';
import '../../../services/app_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
    _NavItem(Icons.people_outline, Icons.people_rounded, 'Users'),
    _NavItem(Icons.directions_car_outlined, Icons.directions_car_rounded, 'Cars'),
    _NavItem(Icons.work_outline, Icons.work_rounded, 'Work Posts'),
  ];

  Widget get _currentScreen {
    switch (_selectedIndex) {
      case 0: return const _AdminHome();
      case 1: return const _AdminUsers();
      case 2: return const _AdminCars();
      case 3: return const _AdminWorkPosts();
      default: return const _AdminHome();
    }
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen(appState: AppState())),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;

    if (isWide) {
      return Scaffold(
        body: Row(children: [_buildRail(), Expanded(child: _currentScreen)]),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary, foregroundColor: Colors.white,
        title: Text(_navItems[_selectedIndex].label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        actions: [IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white70), onPressed: _logout, tooltip: 'Logout')],
      ),
      drawer: Drawer(child: _buildDrawer()),
      body: _currentScreen,
    );
  }

  Widget _buildRail() {
    return Container(
      width: 220,
      decoration: const BoxDecoration(color: AppColors.surface, border: Border(right: BorderSide(color: AppColors.borderColor))),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 52, 16, 20),
          child: Row(children: [
            Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Text('👑', style: TextStyle(fontSize: 20)))),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Admin Panel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text('Smart Garage', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ]),
        ),
        const Divider(height: 1, color: AppColors.borderColor),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(vertical: 8),
          children: List.generate(_navItems.length, (i) {
            final item = _navItems[i]; final sel = _selectedIndex == i;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: sel ? AppColors.accentLight : Colors.transparent, borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(sel ? item.activeIcon : item.icon, color: sel ? AppColors.primary : AppColors.textSecondary, size: 22),
                title: Text(item.label, style: TextStyle(fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? AppColors.primary : AppColors.textSecondary)),
                onTap: () => setState(() => _selectedIndex = i),
              ),
            );
          }),
        )),
        const Divider(height: 1, color: AppColors.borderColor),
        ListTile(leading: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
          title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
          onTap: _logout),
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _buildDrawer() {
    return Column(children: [
      Container(padding: const EdgeInsets.fromLTRB(16, 48, 16, 20), color: AppColors.primary,
        child: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('👑', style: TextStyle(fontSize: 20)))),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Admin Panel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
            Text('Smart Garage Gujarat', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ]),
        ]),
      ),
      Expanded(child: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
        ...List.generate(_navItems.length, (i) {
          final item = _navItems[i]; final sel = _selectedIndex == i;
          return ListTile(
            leading: Icon(sel ? item.activeIcon : item.icon, color: sel ? AppColors.primary : AppColors.textSecondary),
            title: Text(item.label, style: TextStyle(fontWeight: sel ? FontWeight.w700 : FontWeight.w500, color: sel ? AppColors.primary : AppColors.textPrimary)),
            selected: sel, selectedTileColor: AppColors.accentLight,
            onTap: () { setState(() => _selectedIndex = i); Navigator.pop(context); },
          );
        }),
        const Divider(),
        ListTile(leading: const Icon(Icons.logout_rounded, color: AppColors.error), title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)), onTap: _logout),
      ])),
    ]);
  }
}

class _NavItem {
  final IconData icon, activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

// ═══════════════════════════════════════════════════════════════════════════════
//  ADMIN HOME — Live stats from Firestore
// ═══════════════════════════════════════════════════════════════════════════════
class _AdminHome extends StatefulWidget {
  const _AdminHome();

  @override
  State<_AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<_AdminHome> {
  Map<String, int> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await FirebaseService.getAdminStats();
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 140, pinned: true, automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Admin Dashboard 👑', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                Text('Live Firestore data · ${_greeting()}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.refresh_rounded, color: Colors.white70), onPressed: () { setState(() => _loading = true); _loadStats(); }),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (_loading)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.primary)))
              else ...[
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
                  children: [
                    _StatCard('${_stats['totalUsers'] ?? 0}', 'Total Users', Icons.people_rounded, AppColors.primary),
                    _StatCard('${_stats['garageOwners'] ?? 0}', 'Garages', Icons.store_rounded, const Color(0xFF6C3483)),
                    _StatCard('${_stats['totalCars'] ?? 0}', 'Cars Registered', Icons.directions_car_rounded, AppColors.success),
                    _StatCard('${_stats['acceptedPosts'] ?? 0}', 'Jobs Done', Icons.check_circle_rounded, Colors.amber.shade700),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Recent Work Posts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                StreamBuilder<List<WorkPost>>(
                  stream: FirebaseService.streamAllWorkPosts(),
                  builder: (ctx, snap) {
                    final posts = (snap.data ?? []).take(5).toList();
                    if (posts.isEmpty) return const _EmptyState('No work posts yet');
                    return Column(children: posts.map((p) => _RecentPostTile(post: p)).toList());
                  },
                ),
              ],
            ]),
          ),
        ),
      ]),
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  ADMIN USERS
// ═══════════════════════════════════════════════════════════════════════════════
class _AdminUsers extends StatefulWidget {
  const _AdminUsers();

  @override
  State<_AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<_AdminUsers> {
  String _search = '';
  String _roleFilter = 'All';
  final List<String> _roles = ['All', 'Car Owner', 'Garage Owner'];

  Future<void> _delete(UserModel user) async {
    final ok = await _confirmDialog(context, 'Delete User', 'Delete ${user.name}? This will also delete all their cars and work posts.');
    if (!ok) return;
    try {
      await FirebaseService.deleteUser(user.id);
      if (mounted) showSnackBar(context, 'User deleted');
    } catch (e) {
      if (mounted) showSnackBar(context, 'Delete failed: $e', isError: true);
    }
  }

  Future<void> _toggleActive(UserModel user, bool isActive) async {
    try {
      await FirebaseService.toggleUserActive(user.id, isActive);
      if (mounted) showSnackBar(context, isActive ? 'User activated' : 'User deactivated');
    } catch (e) {
      if (mounted) showSnackBar(context, 'Failed: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, automaticallyImplyLeading: false,
        title: const Text('Users Management', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Column(children: [
        Container(color: AppColors.surface, padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: TextField(onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: const InputDecoration(hintText: 'Search by name or email...', prefixIcon: Icon(Icons.search), contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)))),
            const SizedBox(width: 10),
            DropdownButton<String>(value: _roleFilter,
              items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _roleFilter = v ?? 'All')),
          ]),
        ),
        Expanded(child: StreamBuilder<List<UserModel>>(
          stream: FirebaseService.streamAllUsers(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const _Loader();
            if (snap.hasError) return _ErrorState('${snap.error}');
            var users = snap.data ?? [];
            if (_search.isNotEmpty) users = users.where((u) => u.name.toLowerCase().contains(_search) || u.email.toLowerCase().contains(_search)).toList();
            if (_roleFilter == 'Car Owner') users = users.where((u) => u.isCarOwner).toList();
            if (_roleFilter == 'Garage Owner') users = users.where((u) => u.isGarageOwner).toList();
            if (users.isEmpty) return const _EmptyState('No users found');
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (_, i) => _UserTile(user: users[i], onDelete: () => _delete(users[i]), onToggle: (v) => _toggleActive(users[i], v)),
            );
          },
        )),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  ADMIN CARS
// ═══════════════════════════════════════════════════════════════════════════════
class _AdminCars extends StatefulWidget {
  const _AdminCars();

  @override
  State<_AdminCars> createState() => _AdminCarsState();
}

class _AdminCarsState extends State<_AdminCars> {
  String _search = '';

  Future<void> _delete(CarModel car) async {
    final ok = await _confirmDialog(context, 'Delete Car', 'Delete ${car.brand} ${car.model} (${car.plateNumber})?');
    if (!ok) return;
    try {
      await FirebaseService.deleteCar(car.id);
      if (mounted) showSnackBar(context, 'Car deleted');
    } catch (e) {
      if (mounted) showSnackBar(context, 'Delete failed: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, automaticallyImplyLeading: false,
        title: const Text('Cars Management', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Column(children: [
        Container(color: AppColors.surface, padding: const EdgeInsets.all(12),
          child: TextField(onChanged: (v) => setState(() => _search = v.toLowerCase()),
            decoration: const InputDecoration(hintText: 'Search by brand, model or plate...', prefixIcon: Icon(Icons.search), contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)))),
        Expanded(child: StreamBuilder<List<CarModel>>(
          stream: FirebaseService.streamAllCars(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const _Loader();
            if (snap.hasError) return _ErrorState('${snap.error}');
            var cars = snap.data ?? [];
            if (_search.isNotEmpty) cars = cars.where((c) => '${c.brand} ${c.model} ${c.plateNumber}'.toLowerCase().contains(_search)).toList();
            if (cars.isEmpty) return const _EmptyState('No cars found');
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cars.length,
              itemBuilder: (_, i) => _CarTile(car: cars[i], onDelete: () => _delete(cars[i])),
            );
          },
        )),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  ADMIN WORK POSTS
// ═══════════════════════════════════════════════════════════════════════════════
class _AdminWorkPosts extends StatefulWidget {
  const _AdminWorkPosts();

  @override
  State<_AdminWorkPosts> createState() => _AdminWorkPostsState();
}

class _AdminWorkPostsState extends State<_AdminWorkPosts> {
  String _search = '';
  String _filter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Accepted', 'Deleted'];

  Future<void> _delete(WorkPost post) async {
    final ok = await _confirmDialog(context, 'Delete Post', 'Permanently delete "${post.title}"?');
    if (!ok) return;
    try {
      await FirebaseService.hardDeleteWorkPost(post.id);
      if (mounted) showSnackBar(context, 'Post deleted');
    } catch (e) {
      if (mounted) showSnackBar(context, 'Delete failed: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, automaticallyImplyLeading: false,
        title: const Text('Work Posts', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Column(children: [
        Container(color: AppColors.surface, padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: TextField(onChanged: (v) => setState(() => _search = v.toLowerCase()),
              decoration: const InputDecoration(hintText: 'Search posts...', prefixIcon: Icon(Icons.search), contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)))),
            const SizedBox(width: 10),
            DropdownButton<String>(value: _filter,
              items: _filters.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (v) => setState(() => _filter = v ?? 'All')),
          ]),
        ),
        Expanded(child: StreamBuilder<List<WorkPost>>(
          stream: FirebaseService.streamAllWorkPosts(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const _Loader();
            if (snap.hasError) return _ErrorState('${snap.error}');
            var posts = snap.data ?? [];
            if (_search.isNotEmpty) posts = posts.where((p) => p.title.toLowerCase().contains(_search) || p.postedBy.toLowerCase().contains(_search)).toList();
            if (_filter == 'Pending') posts = posts.where((p) => !p.isAccepted && !p.isDeleted).toList();
            if (_filter == 'Accepted') posts = posts.where((p) => p.isAccepted).toList();
            if (_filter == 'Deleted') posts = posts.where((p) => p.isDeleted).toList();
            if (posts.isEmpty) return _EmptyState('No ${_filter.toLowerCase()} posts');
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (_, i) => _WorkPostTile(post: posts[i], onDelete: () => _delete(posts[i])),
            );
          },
        )),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  SHARED TILE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════
class _UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;
  const _UserTile({required this.user, required this.onDelete, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isGarage = user.isGarageOwner;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))]),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: isGarage ? const Color(0xFFF3E5F5) : AppColors.accentLight, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(isGarage ? '🔧' : '🚗', style: const TextStyle(fontSize: 22)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text(user.email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          if (user.garageName != null) Text(user.garageName!, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
          Text('${user.city ?? ''} · ${isGarage ? "Garage Owner" : "Car Owner"}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
        ])),
        Column(children: [
          IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20), onPressed: onDelete),
        ]),
      ]),
    );
  }
}

class _CarTile extends StatelessWidget {
  final CarModel car;
  final VoidCallback onDelete;
  const _CarTile({required this.car, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderColor),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))]),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(car.brandEmoji, style: const TextStyle(fontSize: 22)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${car.brand} ${car.model}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text('${car.plateNumber} · ${car.year} · ${car.fuelType}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text('${car.currentKm} km · ${car.color}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          if (car.isServiceDue) Container(
            margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(10)),
            child: const Text('Service Due', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.error))),
        ])),
        IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20), onPressed: onDelete),
      ]),
    );
  }
}

class _WorkPostTile extends StatelessWidget {
  final WorkPost post;
  final VoidCallback onDelete;
  const _WorkPostTile({required this.post, required this.onDelete});

  Color get _statusColor {
    if (post.isDeleted) return AppColors.error;
    if (post.isAccepted) return AppColors.success;
    return AppColors.warning;
  }

  String get _statusLabel {
    if (post.isDeleted) return 'Deleted';
    if (post.isAccepted) return 'Accepted';
    return 'Pending';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _statusColor.withOpacity(0.3)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))]),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(post.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Text(_statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor))),
          ]),
          const SizedBox(height: 4),
          Text('${post.postedBy} · ${post.category}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text('${post.vehicle} · ${post.location}', style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
          Text(post.amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
          if (post.isAccepted && post.acceptedByName != null)
            Text('Accepted by: ${post.acceptedByName}', style: const TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600)),
        ])),
        IconButton(icon: const Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 20), onPressed: onDelete),
      ]),
    );
  }
}

class _RecentPostTile extends StatelessWidget {
  final WorkPost post;
  const _RecentPostTile({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderColor)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(post.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text('${post.postedBy} · ${post.category}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: post.isAccepted ? AppColors.successLight : AppColors.warningLight, borderRadius: BorderRadius.circular(10)),
          child: Text(post.isAccepted ? 'Done' : 'Open', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: post.isAccepted ? AppColors.success : AppColors.warning))),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard(this.value, this.label, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.borderColor),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))]),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ])),
      ]),
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();
  @override
  Widget build(BuildContext context) => const Center(child: CircularProgressIndicator(color: AppColors.primary));
}

class _EmptyState extends StatelessWidget {
  final String msg;
  const _EmptyState(this.msg);
  @override
  Widget build(BuildContext context) => Center(child: Text(msg, style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)));
}

class _ErrorState extends StatelessWidget {
  final String msg;
  const _ErrorState(this.msg);
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Error: $msg', style: const TextStyle(color: AppColors.error))));
}

Future<bool> _confirmDialog(BuildContext context, String title, String msg) async {
  return await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Text(msg),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Confirm')),
      ],
    ),
  ) ?? false;
}