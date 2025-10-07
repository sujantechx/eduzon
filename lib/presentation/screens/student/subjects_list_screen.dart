// lib/presentation/screens/student/subjects_list_screen.dart
import 'package:eduzon/data/models/subject_model.dart';
import 'package:eduzon/data/repositories/admin_repository.dart';
import 'package:eduzon/logic/auth/auth_bloc.dart';
import 'package:eduzon/logic/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';

class SubjectsListScreen extends StatefulWidget {
  const SubjectsListScreen({super.key});

  @override
  State<SubjectsListScreen> createState() => _SubjectsListScreenState();
}

class _SubjectsListScreenState extends State<SubjectsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGrid = false;
  bool _loading = true;
  String _error = '';
  List<SubjectModel> _subjects = [];
  List<SubjectModel> _filtered = [];

  @override
  void initState() {
    super.initState();
    _load();
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
      setState(() => _filtered = List.from(_subjects));
      return;
    }
    setState(() {
      _filtered = _subjects.where((s) {
        final t = (s.title ?? '').toLowerCase();
        final d = (s.description ?? '').toLowerCase();
        return t.contains(q) || d.contains(q) || (s.subjectNumber?.toString() ?? '').contains(q);
      }).toList();
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is! Authenticated) {
        setState(() {
          _subjects = [];
          _filtered = [];
          _loading = false;
        });
        return;
      }

      final user = authState.userModel;
      final courseId = user.courseId;
      if (courseId == null || courseId.isEmpty) {
        setState(() {
          _subjects = [];
          _filtered = [];
          _loading = false;
        });
        return;
      }

      final subjects = await context.read<AdminRepository>().getSubjects(courseId: courseId);
      subjects.sort((a, b) {
        if (a.subjectNumber != null && b.subjectNumber != null) return a.subjectNumber!.compareTo(b.subjectNumber!);
        if (a.subjectNumber != null) return -1;
        if (b.subjectNumber != null) return 1;
        return (a.title ?? '').compareTo(b.title ?? '');
      });

      setState(() {
        _subjects = subjects;
        _filtered = List.from(subjects);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _openChapters(SubjectModel subject) {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      final user = authState.userModel;
      context.push(AppRoutes.chaptersList, extra: {'subject': subject, 'courseId': user.courseId});
    }
  }

  Widget _cardFor(SubjectModel subject) {
    return InkWell(
      onTap: () => _openChapters(subject),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.blue.shade50,
                child: Text(
                  subject.subjectNumber != null ? '${subject.subjectNumber}' : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject.title ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(subject.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right)
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridTileFor(SubjectModel s) {
    return InkWell(
      onTap: () => _openChapters(s),
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue.shade50,
                child: Text(s.subjectNumber != null ? '${s.subjectNumber}' : '?', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
              const SizedBox(height: 12),
              Text(s.title ?? 'Untitled', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Expanded(child: Text(s.description ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 13))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isGrid = !_isGrid),
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            tooltip: 'Toggle view',
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search subjects',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(onPressed: () => _searchController.clear(), icon: const Icon(Icons.clear))
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Builder(builder: (context) {
                  if (_loading) return const Center(child: CircularProgressIndicator());
                  if (_error.isNotEmpty) return Center(child: Text('Error: $_error'));
                  if (_filtered.isEmpty) return Center(child: Text('No subjects available'));

                  return _isGrid
                      ? GridView.builder(
                    itemCount: _filtered.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9),
                    itemBuilder: (context, index) => _gridTileFor(_filtered[index]),
                  )
                      : ListView.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _cardFor(_filtered[index]),
                  );
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
