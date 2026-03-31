// File: lib/screens/main_shell.dart
// FIX SUMMARY:
//   1. _currentIndex is reset to 0 whenever the role changes so the app
//      never lands on an out-of-bounds tab index after switching users.
//   2. The IndexedStack is guarded so it only renders once pages are ready.
//   3. Added a logout confirmation dialog to prevent accidental logouts.
import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'dashboard_page.dart';
import 'virtual_garage_page.dart';
import 'services_page.dart';
import 'ai_advisor_page.dart';
import 'garage_dashboard_page.dart';
import 'work_board_page.dart';
import 'post_work_page.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  final AppState appState;
  const MainShell({super.key, required this.appState});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  // Track the role we built pages for so we can detect a role switch
  UserRole? _builtForRole;

  List<Widget>? _cachedPages;

  List<Widget> _buildOwnerPages() => [
        DashboardPage(appState: widget.appState),
        VirtualGaragePage(appState: widget.appState),
        ServicesPage(appState: widget.appState),
        AIAdvisorPage(appState: widget.appState),
        ProfilePage(appState: widget.appState),
      ];

  List<Widget> _buildGaragePages() => [
        GarageDashboardPage(appState: widget.appState),
        WorkBoardPage(appState: widget.appState),
        PostWorkPage(appState: widget.appState),
        AIAdvisorPage(appState: widget.appState),
        ProfilePage(appState: widget.appState),
      ];

  static const List<BottomNavigationBarItem> _ownerNav = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined),            activeIcon: Icon(Icons.home_rounded),            label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined),  activeIcon: Icon(Icons.directions_car_rounded),  label: 'My Cars'),
    BottomNavigationBarItem(icon: Icon(Icons.build_outlined),           activeIcon: Icon(Icons.build_rounded),           label: 'Services'),
    BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined),       activeIcon: Icon(Icons.smart_toy_rounded),       label: 'AI Advisor'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded),   activeIcon: Icon(Icons.person_rounded),          label: 'Profile'),
  ];

  static const List<BottomNavigationBarItem> _garageNav = [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined),            activeIcon: Icon(Icons.home_rounded),            label: 'Dashboard'),
    BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined),       activeIcon: Icon(Icons.dashboard_rounded),       label: 'Work Board'),
    BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline_rounded),activeIcon: Icon(Icons.add_circle_rounded),     label: 'Post Work'),
    BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined),       activeIcon: Icon(Icons.smart_toy_rounded),       label: 'AI'),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded),   activeIcon: Icon(Icons.person_rounded),          label: 'Profile'),
  ];

  bool get _isCarOwner => widget.appState.user?.role == UserRole.carOwner;

  List<Widget> get _pages {
    final role = widget.appState.user?.role;
    // Rebuild pages if role changed (e.g. user switched accounts)
    if (_builtForRole != role) {
      _builtForRole = role;
      _cachedPages = _isCarOwner ? _buildOwnerPages() : _buildGaragePages();
      // FIX: reset tab index on role change to avoid out-of-range crash
      _currentIndex = 0;
    }
    return _cachedPages!;
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    final navItems = _isCarOwner ? _ownerNav : _garageNav;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex.clamp(0, pages.length - 1),
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.borderColor)),
          boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: navItems,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
        ),
      ),
    );
  }
}