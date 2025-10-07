// lib/presentation/screens/courses/my_courses_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduzon/core/routes/app_routes.dart';
import 'package:eduzon/data/models/courses_moddel.dart';
import 'package:eduzon/data/models/user_model.dart';
import 'package:eduzon/logic/auth/auth_bloc.dart';
import 'package:eduzon/logic/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// A modern "My Courses" page.
///
/// Behavior/assumptions:
/// - Reads current user from AuthCubit (must be authenticated).
/// - If user.enrolledCourseIds (List<String>) exists it will load those courses from Firestore.
/// - Otherwise, if user.courseId (single) exists it will load that single course.
/// - Shows search, list/grid toggle, pull-to-refresh, and empty state.
class MyCoursesPage extends StatefulWidget {
  const MyCoursesPage({super.key});

  @override
  State<MyCoursesPage> createState() => _MyCoursesPageState();
}

class _MyCoursesPageState extends State<MyCoursesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  bool _isGrid = false;
  bool _isLoading = false;
  List<CoursesModel> _courses = [];
  List<CoursesModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applySearch);
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch() {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filtered = List.from(_courses));
      return;
    }

    setState(() {
      _filtered = _courses.where((c) {
        final title = (c.title ?? '').toLowerCase();
        final desc = (c.description ?? '').toLowerCase();
        return title.contains(q) || desc.contains(q);
      }).toList();
    });
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    try {
      final state = context.read<AuthCubit>().state;
      if (state is! Authenticated) {
        // not authenticated; show empty
        setState(() {
          _courses = [];
          _filtered = [];
        });
        return;
      }

      final UserModel user = state.userModel;

      List<String> ids = [];
      if (user.courseId != null && user.courseId!.isNotEmpty) {
        ids = List.from(user.courseId! as Iterable);
      } else if (user.courseId != null && user.courseId!.isNotEmpty) {
        ids = [user.courseId!];
      }

      if (ids.isEmpty) {
        setState(() {
          _courses = [];
          _filtered = [];
        });
        return;
      }

      // Batch fetch documents by id. Firestore `whereIn` supports up to 10 ids per query.
      final List<CoursesModel> loaded = [];
      const batchSize = 10;
      for (var i = 0; i < ids.length; i += batchSize) {
        final chunk = ids.sublist(i, (i + batchSize).clamp(0, ids.length));
        final snapshot = await _firestore.collection('courses').where(FieldPath.documentId, whereIn: chunk).get();
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final model = CoursesModel.fromSnapshot(doc);
          loaded.add(model);
        }
      }

      // sort loaded by title
      loaded.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));

      setState(() {
        _courses = loaded;
        _filtered = List.from(loaded);
      });
    } catch (e, st) {
      // ignore - show empty and a snack
      debugPrint('Failed to load courses: $e\n$st');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load courses')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    await _loadCourses();
  }

  void _openCourseDetail(CoursesModel course) {
    // Pass the full model to the course detail screen
    context.push(AppRoutes.courseDetail, extra: course);
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text('No courses found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('You are not enrolled in any courses yet. Browse the catalog to enroll.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.publicCourses),
              icon: const Icon(Icons.explore),
              label: const Text('Browse Courses'),
            )
          ],
        ),
      ),
    );
  }

  Widget _courseCard(CoursesModel course) {
    return InkWell(
      onTap: () => _openCourseDetail(course),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 86,
                  height: 66,
                  child: course.imageUrl != null && course.imageUrl!.isNotEmpty
                      ? Image.network(course.imageUrl!, fit: BoxFit.cover, errorBuilder: (c, e, s) => _thumbPlaceholder())
                      : _thumbPlaceholder(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(
                      course.description ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${course.price ?? 0}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _openCourseDetail(course),
                    child: const Text('Open'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumbPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.image, size: 28, color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
            tooltip: 'Toggle view',
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search your courses',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                  ? _emptyState()
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _isGrid
                    ? GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.7,
                  ),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) => _courseCard(_filtered[index]),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) => _courseCard(_filtered[index]),
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
