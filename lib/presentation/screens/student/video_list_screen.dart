// lib/presentation/screens/student/videos_list_screen.dart

import 'package:eduzon/data/repositories/admin_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/models/video_model.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';

class VideosListScreen extends StatelessWidget {
  final String courseId;
  final SubjectModel subject;
  final ChapterModel chapter;
  const VideosListScreen({
    super.key,
    required this.subject,
    required this.chapter,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    // You're correctly handling the authState here, which is great.
    final authState = context.watch<AuthCubit>().state;
    if (authState is! Authenticated) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text(chapter.title)),
      body: FutureBuilder<List<VideoModel>>(
        // ✅ CORRECTED: Use the courseId parameter from the constructor.
        future: context.read<AdminRepository>().getVideos(
          subjectId: subject.id,
          chapterId: chapter.id,
          courseId: courseId, // <-- This is the fix
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No videos found for this chapter.'),
            );
          }

          final videos = snapshot.data!;
          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.play_circle_fill_rounded, color: Colors.red),
                  title: Text(video.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Duration: ${video.duration}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Navigate to the video player with the YouTube videoId.
                    context.push('${AppRoutes.videoPlayer}/${video.videoId}');
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