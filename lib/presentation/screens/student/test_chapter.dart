// lib/presentation/screens/student/chapters_list_screen.dart

import 'package:eduzon/data/models/user_model.dart';
import 'package:eduzon/data/repositories/admin_repository.dart';
import 'package:eduzon/data/repositories/test_repository.dart';
import 'package:eduzon/logic/auth/auth_bloc.dart';
import 'package:eduzon/logic/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/models/result_model.dart';

class TestChapter extends StatelessWidget {
  final SubjectModel subject;
  final String courseId;

  const TestChapter({
    super.key,
    required this.subject,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subject.title)),
      body: FutureBuilder<List<ChapterModel>>(
        future: context.read<AdminRepository>().getChapters(subjectId: subject.id, courseId: courseId),
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
                  onTap: () async {
                    // Check for existing quiz result before navigating
                    final authState = context.read<AuthCubit>().state;
                    if (authState is Authenticated) {
                      final userId = authState.userModel.uid;

                      // Use a temporary repository instance for the check
                      final testRepository = context.read<AdminRepository>();
                      final existingResult = await testRepository.getResultForUserAndChapter(
                        userId: userId,
                        chapterId: chapter.id,
                      );

                      if (existingResult != null) {
                        // If a result exists, navigate directly to the results screen.
                        // You'll need to fetch the questions here to pass to the results screen.
                        final questions = await context.read<AdminRepository>().getQuestions(
                          courseId: courseId,
                          subjectId: subject.id,
                          chapterId: chapter.id,
                        );
                        context.push(
                          AppRoutes.quizResult,
                          extra: {
                            'result': existingResult,
                            'questions': questions,
                            'courseId': courseId,
                            'subjectId': subject.id,
                            'chapterId': chapter.id,
                          },
                        );
                      } else {
                        // If no result exists, navigate to the quiz screen.
                        context.push(
                          AppRoutes.testScreen,
                          extra: {
                            'subject': subject,
                            'chapter': chapter,
                            'courseId': courseId,
                          },
                        );
                      }
                    } else {
                      // Handle unauthenticated user case, perhaps redirect to login
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