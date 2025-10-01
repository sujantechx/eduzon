// lib/presentation/screens/student/subjects_list_screen.dart
import 'package:eduzon/data/repositories/admin_repository.dart';
import 'package:eduzon/logic/auth/auth_bloc.dart';
import 'package:eduzon/logic/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/subject_model.dart';

class SubjectPdf extends StatelessWidget {
  const SubjectPdf({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! Authenticated) {
      return const Center(child: CircularProgressIndicator()); // Handle loading/unauthenticated states
    }

    final user = authState.userModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Subjects PDF')),
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

          final subjects = snapshot.data!;
          return ListView.builder(
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.topic_rounded, color: Colors.blueAccent),
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
                        AppRoutes.chapterPDF,
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
  }}
