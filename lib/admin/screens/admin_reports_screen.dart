// File: lib/admin/screens/admin_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_garage_gujarat/utils/helpers.dart';
import '../../utils/constants.dart';
import '../services/admin_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await AdminService.getStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'System Reports',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Overview of platform statistics and analytics',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                // Statistics Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _ReportCard(
                      title: 'Total Users',
                      value: '${_stats['totalUsers'] ?? 0}',
                      subtitle: '+${_stats['newUsersThisWeek'] ?? 0} this week',
                      icon: Icons.people,
                      color: AppColors.primary,
                    ),
                    _ReportCard(
                      title: 'Total Cars',
                      value: '${_stats['totalCars'] ?? 0}',
                      subtitle: 'Registered vehicles',
                      icon: Icons.directions_car,
                      color: AppColors.success,
                    ),
                    _ReportCard(
                      title: 'Total Bookings',
                      value: '${_stats['totalBookings'] ?? 0}',
                      subtitle: '+${_stats['newBookingsThisWeek'] ?? 0} this week',
                      icon: Icons.book_online,
                      color: Colors.purple,
                    ),
                    _ReportCard(
                      title: 'Work Posts',
                      value: '${_stats['totalWorkPosts'] ?? 0}',
                      subtitle: 'Active listings',
                      icon: Icons.work,
                      color: AppColors.warning,
                    ),
                    _ReportCard(
                      title: 'Garages',
                      value: '${_stats['totalGarages'] ?? 0}',
                      subtitle: 'Registered garages',
                      icon: Icons.store,
                      color: Colors.orange,
                    ),
                    _ReportCard(
                      title: 'Conversion Rate',
                      value: '68%',
                      subtitle: 'Bookings to services',
                      icon: Icons.trending_up,
                      color: Colors.teal,
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Export Button
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.download, size: 32, color: AppColors.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Export Reports',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Download system data in CSV format',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Implement export functionality
                            showSnackBar(context, 'Export feature coming soon');
                          },
                          icon: const Icon(Icons.download),
                          label: const Text('Export'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Recent Activity
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 5,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.accentLight,
                                child: Icon(
                                  _getActivityIcon(index),
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              title: Text(_getActivityTitle(index)),
                              subtitle: Text(_getActivityDescription(index)),
                              trailing: Text(
                                _getActivityTime(index),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(int index) {
    switch (index) {
      case 0:
        return Icons.person_add;
      case 1:
        return Icons.directions_car;
      case 2:
        return Icons.work;
      case 3:
        return Icons.book_online;
      default:
        return Icons.store;
    }
  }

  String _getActivityTitle(int index) {
    switch (index) {
      case 0:
        return 'New user registered';
      case 1:
        return 'New car added';
      case 2:
        return 'Work post created';
      case 3:
        return 'New booking';
      default:
        return 'New garage registered';
    }
  }

  String _getActivityDescription(int index) {
    switch (index) {
      case 0:
        return 'Rajesh Patel joined as Car Owner';
      case 1:
        return 'Maruti Suzuki Swift added';
      case 2:
        return 'Oil Change service posted';
      case 3:
        return 'Service booking from Ahmedabad';
      default:
        return 'Patel Auto Service registered';
    }
  }

  String _getActivityTime(int index) {
    return '${index + 1} hour${index == 0 ? '' : 's'} ago';
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: color),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}