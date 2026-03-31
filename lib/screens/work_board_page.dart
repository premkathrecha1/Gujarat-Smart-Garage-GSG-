// lib/screens/work_board_page.dart
// Reads open work posts from Firestore in real-time.
// Accept button writes to Firestore via FirebaseService.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/work_post.dart';
import '../services/app_state.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class WorkBoardPage extends StatefulWidget {
  final AppState appState;
  const WorkBoardPage({super.key, required this.appState});

  @override
  State<WorkBoardPage> createState() => _WorkBoardPageState();
}

class _WorkBoardPageState extends State<WorkBoardPage> {
  String _filterCategory = 'All';
  final List<String> _categories = [
    'All', 'Mechanical', 'AC & Cooling', 'Body Work & Painting',
    'Electrical', 'Tyres', 'Diagnostics', 'Other',
  ];

  Future<void> _accept(WorkPost post) async {
    final user = widget.appState.user;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Accept This Job?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(post.title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('${post.vehicle} · ${post.location}', style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(post.amount, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Accept Job')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await widget.appState.acceptWorkInFirebase(post.id);
      if (mounted) {
        showSnackBar(context, '✅ Job accepted! Navigate to ${post.location}');
      }
    } catch (e) {
      if (mounted) showSnackBar(context, 'Failed to accept: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Work Board 📌', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            height: 48,
            color: AppColors.surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat == _filterCategory;
                return GestureDetector(
                  onTap: () => setState(() => _filterCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.accentLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppColors.primary : AppColors.borderColor),
                    ),
                    child: Center(child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : AppColors.textSecondary))),
                  ),
                );
              },
            ),
          ),
          // Live stream from Firestore
          Expanded(
            child: StreamBuilder<List<WorkPost>>(
              stream: FirebaseService.streamOpenWorkPosts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError) {
                  // Fallback to local data on error
                  return _buildLocalFallback();
                }

                var posts = snapshot.data ?? [];
                // Filter by category
                if (_filterCategory != 'All') {
                  posts = posts.where((p) => p.category == _filterCategory).toList();
                }
                // Exclude own posts (garage shouldn't accept their own jobs)
                final myId = widget.appState.user?.id ?? '';
                posts = posts.where((p) => p.garageId != myId).toList();

                if (posts.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('📭', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(_filterCategory == 'All' ? 'No open jobs right now' : 'No $_filterCategory jobs available',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      const Text('Check back later or change the filter', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ]),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderColor)),
                      child: Row(children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(child: Text('${posts.length} live job${posts.length == 1 ? '' : 's'} from Firestore. Accept to take ownership.',
                          style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600))),
                      ]),
                    ),
                    ...posts.map((p) => _WorkCard(post: p, onAccept: () => _accept(p))),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalFallback() {
    // Show appState.workPosts when Firestore is unavailable
    final posts = widget.appState.workPosts.where((p) => !p.isAccepted && !p.isDeleted).toList();
    if (posts.isEmpty) return const Center(child: Text('No work posts available', style: TextStyle(color: AppColors.textSecondary)));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: posts.map((p) => _WorkCard(post: p, onAccept: () {
        widget.appState.acceptWork(p.id);
        showSnackBar(context, 'Accepted (offline mode)');
      })).toList(),
    );
  }
}

class _WorkCard extends StatelessWidget {
  final WorkPost post;
  final VoidCallback onAccept;
  const _WorkCard({required this.post, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: post.isAccepted ? AppColors.success : AppColors.borderColor),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: post.isAccepted ? AppColors.successLight : AppColors.accentLight,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(post.vehicle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _catColor(post.category).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(post.category, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _catColor(post.category))),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(post.postedBy, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Flexible(child: Text(post.location, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.currency_rupee, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(post.amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Flexible(child: Text(post.time, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
            ]),
            if (post.notes != null && post.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(post.notes!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
            ],
            if (!post.isAccepted) ...[
              const SizedBox(height: 12),
              SizedBox(width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: const Text('Accept Job'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                )),
            ] else ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Accepted${post.acceptedByName != null ? " by ${post.acceptedByName}" : ""}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success))),
                ]),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'Mechanical': return AppColors.primary;
      case 'AC & Cooling': return Colors.cyan.shade700;
      case 'Body Work & Painting': return Colors.orange.shade700;
      case 'Electrical': return Colors.amber.shade700;
      case 'Tyres': return Colors.grey.shade700;
      case 'Diagnostics': return Colors.purple.shade700;
      default: return AppColors.textSecondary;
    }
  }
}