// lib/screens/post_work_page.dart
// Garage owner posts a work job → saves to Firestore
// Shows the garage's own posted jobs with delete option
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/work_post.dart';
import '../services/app_state.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class PostWorkPage extends StatefulWidget {
  final AppState appState;
  const PostWorkPage({super.key, required this.appState});

  @override
  State<PostWorkPage> createState() => _PostWorkPageState();
}

class _PostWorkPageState extends State<PostWorkPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Form fields
  final _titleCtrl = TextEditingController();
  final _vehicleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  String _category = 'Mechanical';
  bool _isPosting = false;

  final List<String> _categories = [
    'Mechanical', 'AC & Cooling', 'Body Work & Painting',
    'Electrical', 'Tyres', 'Diagnostics', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _titleCtrl.dispose();
    _vehicleCtrl.dispose();
    _amountCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _postWork() async {
    if (_titleCtrl.text.trim().isEmpty || _locationCtrl.text.trim().isEmpty) {
      showSnackBar(context, 'Service title and location are required', isError: true);
      return;
    }
    setState(() => _isPosting = true);

    final post = WorkPost(
      id: '',
      title: _titleCtrl.text.trim(),
      vehicle: _vehicleCtrl.text.trim().isEmpty ? 'Any' : _vehicleCtrl.text.trim(),
      postedBy: widget.appState.user?.garageName ?? widget.appState.user?.name ?? 'Garage',
      garageId: widget.appState.user?.id ?? '',
      distanceKm: 0,
      amount: _amountCtrl.text.trim().isEmpty ? 'Negotiable' : '₹${_amountCtrl.text.trim()}',
      time: _timeCtrl.text.trim().isEmpty ? 'Flexible' : _timeCtrl.text.trim(),
      category: _category,
      location: _locationCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    try {
      await widget.appState.postWorkToFirebase(post);
      if (mounted) {
        showSnackBar(context, '✅ Work posted! Nearby garages can now see it.');
        _clearForm();
        _tabCtrl.animateTo(1); // Switch to "My Posts" tab
      }
    } catch (e) {
      if (mounted) showSnackBar(context, 'Failed to post: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  void _clearForm() {
    _titleCtrl.clear();
    _vehicleCtrl.clear();
    _amountCtrl.clear();
    _locationCtrl.clear();
    _notesCtrl.clear();
    _timeCtrl.clear();
    setState(() => _category = 'Mechanical');
  }

  Future<void> _deletePost(WorkPost post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Post?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Delete "${post.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await widget.appState.deleteWorkPostFromFirebase(post.id);
        if (mounted) showSnackBar(context, 'Post deleted');
      } catch (e) {
        if (mounted) showSnackBar(context, 'Delete failed: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Post Work 📢', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            const Tab(text: 'New Post'),
            Tab(text: 'My Posts (${widget.appState.workPosts.where((p) => !p.isDeleted).length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildPostForm(),
          _buildMyPosts(),
        ],
      ),
    );
  }

  Widget _buildPostForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderColor)),
          child: const Row(children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
            SizedBox(width: 10),
            Expanded(child: Text('Post overflow jobs. Other garages nearby can accept and take over.', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600))),
          ]),
        ),
        const SizedBox(height: 20),

        _label('Service Title *'),
        TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'e.g. Engine Oil Change + Filter', prefixIcon: Icon(Icons.build_outlined, color: AppColors.primary, size: 20))),
        const SizedBox(height: 14),

        _label('Vehicle (optional)'),
        TextField(controller: _vehicleCtrl, decoration: const InputDecoration(hintText: 'e.g. Maruti Swift, Any', prefixIcon: Icon(Icons.directions_car_outlined, color: AppColors.primary, size: 20))),
        const SizedBox(height: 14),

        _label('Category'),
        DropdownButtonFormField<String>(
          value: _category,
          decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined, color: AppColors.primary, size: 20)),
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => _category = v ?? _category),
        ),
        const SizedBox(height: 14),

        _label('Location *'),
        TextField(controller: _locationCtrl, decoration: const InputDecoration(hintText: 'e.g. Satellite, Ahmedabad', prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20))),
        const SizedBox(height: 14),

        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('Amount (₹)'),
            TextField(controller: _amountCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '1200', prefixIcon: Icon(Icons.currency_rupee, color: AppColors.primary, size: 20))),
          ])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('Time Slot'),
            TextField(controller: _timeCtrl, decoration: const InputDecoration(hintText: 'Today 3–5 PM', prefixIcon: Icon(Icons.access_time_outlined, color: AppColors.primary, size: 20))),
          ])),
        ]),
        const SizedBox(height: 14),

        _label('Notes (optional)'),
        TextField(controller: _notesCtrl, maxLines: 3,
          decoration: const InputDecoration(hintText: 'Any special instructions, tools needed, etc.', prefixIcon: Icon(Icons.notes_outlined, color: AppColors.primary, size: 20))),
        const SizedBox(height: 24),

        SizedBox(width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isPosting ? null : _postWork,
            icon: _isPosting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send_rounded),
            label: Text(_isPosting ? 'Posting to Firebase...' : 'Post Work Job ☁️'),
          )),
        const SizedBox(height: 16),
      ]),
    );
  }

  Widget _buildMyPosts() {
    final posts = widget.appState.workPosts.where((p) => !p.isDeleted).toList();

    if (posts.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text("You haven't posted any jobs yet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text('Use the "New Post" tab to post overflow work', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ElevatedButton.icon(onPressed: () => _tabCtrl.animateTo(0), icon: const Icon(Icons.add), label: const Text('Post New Job')),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (ctx, i) => _MyPostCard(post: posts[i], onDelete: () => _deletePost(posts[i])),
    );
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.4)));
}

class _MyPostCard extends StatelessWidget {
  final WorkPost post;
  final VoidCallback onDelete;
  const _MyPostCard({required this.post, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isAccepted = post.isAccepted;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isAccepted ? AppColors.success : AppColors.borderColor),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(post.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAccepted ? AppColors.successLight : AppColors.warningLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(isAccepted ? '✅ Accepted' : '⏳ Pending',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isAccepted ? AppColors.success : AppColors.warning)),
          ),
        ]),
        const SizedBox(height: 8),
        _row(Icons.category_outlined, post.category),
        _row(Icons.directions_car_outlined, post.vehicle),
        _row(Icons.location_on_outlined, post.location),
        _row(Icons.currency_rupee, post.amount),
        _row(Icons.access_time_outlined, post.time),
        if (isAccepted && post.acceptedByName != null)
          _row(Icons.store_rounded, 'Accepted by: ${post.acceptedByName}', color: AppColors.success),
        if (post.notes != null && post.notes!.isNotEmpty)
          _row(Icons.notes_outlined, post.notes!),
        if (!isAccepted) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
              label: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _row(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: color ?? AppColors.textSecondary))),
      ]),
    );
  }
}