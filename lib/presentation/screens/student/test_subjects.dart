import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';

class TestSubjects extends StatelessWidget {
  const TestSubjects({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! Authenticated) {
      return const Center(child: CircularProgressIndicator()); // Handle loading/unauthenticated states
    }

    final user = authState.userModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Subjects Test')),
      body: FutureBuilder<List<SubjectModel>>(
        // Listen to the stream of subjects from the repository.
        future: context.read<AdminRepository>().getSubjects(courseId: user.courseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No subjects available for this course.'));
          }
          final sortedSubjects = List<SubjectModel>.from(snapshot.data!)
            ..sort((a, b) {
              // If both have a number, sort numerically
              if (a.subjectNumber != null && b.subjectNumber != null) {
                return a.subjectNumber!.compareTo(b.subjectNumber!);
              }
              // If 'a' has a number and 'b' doesn't, 'a' comes first
              else if (a.subjectNumber != null && b.subjectNumber == null) {
                return -1;
              }
              // If 'b' has a number and 'a' doesn't, 'b' comes first
              else if (a.subjectNumber == null && b.subjectNumber != null) {
                return 1;
              }
              // If neither has a number, sort by title as a fallback
              else {
                return a.title.compareTo(b.title);
              }
            });

          final subjects = snapshot.data!;
          return ListView.builder(
            itemCount: sortedSubjects.length,
            itemBuilder: (context, index) {
              final subject = sortedSubjects[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Container(
                    width: 60,
                    child: Row(
                      children: [
                        Text(
                          subject.subjectNumber != null ? '${subject.subjectNumber}.' : '0',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Icon(Icons.topic, color: Colors.blue),
                      ],
                    ),
                  ),
                  title: Text(subject.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Get the user from the AuthCubit
                    final authState = context.read<AuthCubit>().state;
                    if (authState is Authenticated) {
                      final user = authState.userModel;
                      final courseId = user.courseId;

                      // ✅ CORRECTED: Pass the subject and courseId inside a Map
                      context.push(
                        AppRoutes.testChapter,
                        extra: {
                          'subject': subject,
                          'courseId': courseId,
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

