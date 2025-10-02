// lib/presentation/screens/student/chapters_list_screen.dart
import 'package:eduzon/data/models/pdf_model.dart';
import 'package:eduzon/data/repositories/admin_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';

class ChapterPdf extends StatelessWidget {
  final SubjectModel subject;
  final String courseId; // ✅ CORRECTED: Add courseId parameter
  const ChapterPdf({super.key, required this.subject, required this.courseId});
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
         final sortedChapters = List<ChapterModel>.from(snapshot.data!)
            ..sort((a, b) {
              // If both have a number, sort numerically
              if (a.chapterNumber != null && b.chapterNumber != null) {
                return a.chapterNumber!.compareTo(b.chapterNumber!);
              }
              // If 'a' has a number and 'b' doesn't, 'a' comes first
              else if (a.chapterNumber != null && b.chapterNumber == null) {
                return -1;
              }
              // If 'b' has a number and 'a' doesn't, 'b' comes first
              else if (a.chapterNumber == null && b.chapterNumber != null) {
                return 1;
              }
              // If neither has a number, sort by title as a fallback
              else {
                return a.title.compareTo(b.title);
              }
            });

          final chapters = snapshot.data!;
          return ListView.builder(
            itemCount: sortedChapters.length,
            itemBuilder: (context, index) {
              final chapter = sortedChapters[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading:  Container(
                    width: 60,
                    child: Row(
                      children: [
                       Text(chapter.chapterNumber != null ? chapter.chapterNumber.toString() : ''),
                        const Icon(Icons.article, color: Colors.green),
                      ],
                    ),
                  ),
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
                        AppRoutes.pdfList,
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

