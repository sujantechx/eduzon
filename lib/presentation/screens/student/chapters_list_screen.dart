// lib/presentation/screens/student/chapters_list_screen.dart
import 'package:eduzon/data/repositories/admin_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';

class ChaptersListScreen extends StatelessWidget {
  final SubjectModel subject;
  final String courseId; // You can set this dynamically if needed.
  const ChaptersListScreen({super.key, required this.subject, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is! Authenticated) {
      return const Center(child: CircularProgressIndicator()); // Handle loading/unauthenticated states
    }
    final user = authState.userModel;
    return Scaffold(
      appBar: AppBar(title: Text(subject.title)),
      body: FutureBuilder<List<ChapterModel>>(
        // ✅ CORRECTED: Use the courseId parameter from the constructor.
        future: context.read<AdminRepository>().getChapters(subjectId: subject.id, courseId: user.courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No chapters found for this subject.'));
          }

          final chapters = snapshot.data!;
          return ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.article_rounded, color: Colors.green),
                  title: Text(chapter.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Get the user from the AuthCubit
                    final authState = context.read<AuthCubit>().state;
                    if (authState is Authenticated) {
                      final user = authState.userModel;
                      final courseId = user.courseId;

                      // ✅ CORRECTED: Pass the subject and courseId inside a Map
                      context.push(
                        AppRoutes.videosList,
                        extra: {
                          'subject': subject,
                          'courseId': courseId,
                          'chapter': chapter,
                        },
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}