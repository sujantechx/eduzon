// lib/presentation/screens/student/test_chapter.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eduzon/core/routes/app_routes.dart'; // Ensure this path is correct
import 'package:eduzon/data/models/chapter_model.dart';
import 'package:eduzon/data/models/subject_model.dart';
import 'package:eduzon/data/repositories/admin_repository.dart';
import 'package:eduzon/logic/auth/auth_bloc.dart';
import 'package:eduzon/logic/auth/auth_state.dart';

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
    // Watch AuthCubit state to get user information and rebuild on changes
    final authState = context.watch<AuthCubit>().state;
    if (authState is! Authenticated) {
      // Handle the case where the user is not authenticated.
      return const Center(child: CircularProgressIndicator());
    }
    final user = authState.userModel;

    return Scaffold(
      appBar: AppBar(title: Text(subject.title)),
      body: FutureBuilder<List<ChapterModel>>(
        // Use the user's courseId from the AuthCubit state to fetch chapters
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
                  // Corrected onTap function. The async call is now properly structured.
                  onTap: () async {
                    final authState = context.read<AuthCubit>().state;
                    if (authState is Authenticated) {
                      final user = authState.userModel;
                      final userId = user.uid;
                      final courseIdFromUser = user.courseId; // Get courseId from the user model

                      // Use the repository to check for an existing result.
                      final testRepository = context.read<AdminRepository>();
                      final existingResult = await testRepository.getResultForUserAndChapter(
                        userId: userId,
                        chapterId: chapter.id,
                      );

                      if (existingResult != null) {
                        // If a result exists, fetch the questions and navigate to the result screen.
                        final questions = await testRepository.getQuestions(
                          courseId: courseIdFromUser,
                          subjectId: subject.id,
                          chapterId: chapter.id,
                        );

                        context.go( // Use 'go' for top-level navigation to avoid history stack issues
                          AppRoutes.quizResult,
                          extra: {
                            'result': existingResult,
                            'questions': questions,
                            'courseId': courseIdFromUser,
                            'subjectId': subject.id,
                            'chapterId': chapter.id,
                          },
                        );
                      } else {
                        // If no result exists, navigate to the quiz screen to start a new quiz.
                        context.go( // Use 'go' here as well
                          AppRoutes.testScreen,
                          extra: {
                            'subject': subject,
                            'chapter': chapter,
                            'courseId': courseIdFromUser,
                          },
                        );
                      }
                    } else {
                      // Optionally, handle unauthenticated user (e.g., show a snackbar or redirect)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please log in to take the quiz.')),
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