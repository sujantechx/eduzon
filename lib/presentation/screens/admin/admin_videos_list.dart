// lib/presentation/pages/admin/admin_videos_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/video_model.dart';
import '../../../logic/video/videos_bloc.dart';
import '../../../logic/video/videos_event.dart';
import '../../../logic/video/videos_state.dart';

class AdminVideosList extends StatelessWidget {
  final String courseId;
  final String subjectId;
  final String chapterId;

  const AdminVideosList({
    super.key,
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<VideosBloc, VideosState>(
        listener: (context, state) {
          if (state is VideosError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is VideosLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is VideosLoaded) {
            if (state.videos.isEmpty) {
              return const Center(child: Text('No videos found. Add one!'));
            }
            return ListView.builder(
              itemCount: state.videos.length,
              itemBuilder: (context, index) {
                final video = state.videos[index];
                return InkWell(
                  onTap: () {
                    // Navigate to the ADMIN video player route
                    context.push('${AppRoutes.adminVideoPlayer}/${video.videoId}');
                  },
                  child: ListTile(
                    leading: const Icon(Icons.movie),
                    title: Text(video.title),
                    subtitle: Text('Duration: ${video.duration}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showAddEditVideoDialog(context, video: video),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditVideoDialog(context),
        heroTag: 'videos_fab',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditVideoDialog(BuildContext context, {VideoModel? video}) {
    final isEditing = video != null;
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: isEditing ? video.title : '');
    final videoIdController = TextEditingController(text: isEditing ? video.videoId : '');
    final durationController = TextEditingController(text: isEditing ? video.duration : '');
    final videosBloc = context.read<VideosBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Video' : 'Add Video'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) => v!.trim().isEmpty ? 'Title is required' : null,
                  ),
                  TextFormField(
                    controller: videoIdController,
                    decoration: const InputDecoration(labelText: 'YouTube Video ID'),
                    validator: (v) => v!.trim().isEmpty ? 'Video ID is required' : null,
                  ),
                  TextFormField(
                    controller: durationController,
                    decoration: const InputDecoration(labelText: 'Duration (e.g., 12:34)'),
                    validator: (v) => v!.trim().isEmpty ? 'Duration is required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (isEditing) {
                    videosBloc.add(UpdateVideo(
                      courseId: courseId,
                      subjectId: subjectId,
                      chapterId: chapterId,
                      id: video.id,
                      newTitle: titleController.text,
                      newVideoId: videoIdController.text,
                      newDuration: durationController.text,
                    ));
                  } else {
                    videosBloc.add(AddVideo(
                      courseId: courseId,
                      subjectId: subjectId,
                      chapterId: chapterId,
                      title: titleController.text,
                      videoId: videoIdController.text,
                      duration: durationController.text,
                    ));
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}