// File: lib/admin/screens/admin_work_posts_screen.dart
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../models/work_post.dart';
import '../services/admin_service.dart';

class AdminWorkPostsScreen extends StatefulWidget {
  const AdminWorkPostsScreen({super.key});

  @override
  State<AdminWorkPostsScreen> createState() => _AdminWorkPostsScreenState();
}

class _AdminWorkPostsScreenState extends State<AdminWorkPostsScreen> {
  String _searchQuery = '';
  String _filterStatus = 'All';
  final List<String> _statuses = ['All', 'Pending', 'Accepted'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.borderColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search work posts by title or location...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _filterStatus,
                items: _statuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _filterStatus = value!;
                  });
                },
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _filterStatus = 'All';
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
        ),
        // Work Posts Table
        Expanded(
          child: StreamBuilder<List<WorkPost>>(
            stream: AdminService.getAllWorkPosts(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text('Error loading work posts: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var posts = snapshot.data!;
              
              if (_searchQuery.isNotEmpty) {
                posts = posts.where((post) =>
                  post.title.toLowerCase().contains(_searchQuery) ||
                  post.location.toLowerCase().contains(_searchQuery)
                ).toList();
              }
              
              if (_filterStatus != 'All') {
                posts = posts.where((post) =>
                  (_filterStatus == 'Pending' && !post.isAccepted) ||
                  (_filterStatus == 'Accepted' && post.isAccepted)
                ).toList();
              }

              if (posts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_off, size: 64, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      Text(
                        'No work posts found',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _WorkPostCard(post: post);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WorkPostCard extends StatelessWidget {
  final WorkPost post;

  const _WorkPostCard({required this.post});

  void _showWorkPostDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(post.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: 'Vehicle', value: post.vehicle),
            _InfoRow(label: 'Posted By', value: post.postedBy),
            _InfoRow(label: 'Amount', value: post.amount),
            _InfoRow(label: 'Location', value: post.location),
            _InfoRow(label: 'Distance', value: '${post.distanceKm} km'),
            _InfoRow(label: 'Time', value: post.time),
            _InfoRow(label: 'Category', value: post.category),
            _InfoRow(label: 'Status', value: post.isAccepted ? 'Accepted' : 'Pending'),
            if (post.isAccepted) _InfoRow(label: 'Accepted By', value: post.acceptedBy ?? 'Unknown'),
            _InfoRow(label: 'Post ID', value: post.id),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!post.isAccepted)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // Mark as accepted
                showSnackBar(context, 'Post marked as accepted (demo)');
              },
              child: const Text('Accept Post'),
            ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Work Post'),
                  content: Text('Are you sure you want to delete "${post.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                try {
                  await AdminService.deleteWorkPost(post.id);
                  showSnackBar(context, 'Work post deleted successfully');
                } catch (e) {
                  showSnackBar(context, 'Error deleting work post', isError: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showWorkPostDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: post.isAccepted ? AppColors.successLight : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    post.isAccepted ? Icons.check_circle : Icons.pending,
                    color: post.isAccepted ? AppColors.success : AppColors.warning,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${post.vehicle} • ${post.postedBy}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          post.location,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.attach_money, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          post.amount,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: post.isAccepted ? AppColors.successLight : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      post.isAccepted ? 'Accepted' : 'Pending',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: post.isAccepted ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${post.distanceKm} km',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onPressed: () => _showWorkPostDetails(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// Add this at the end of admin_work_posts_screen.dart
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}