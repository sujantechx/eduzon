// lib/presentation/pages/admin/admin_videos_list.dart
import 'package:eduzon/logic/auth/admin_cubit.dart';
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

            final sortedVideos = List<VideoModel>.from(state.videos)..sort((a, b) {
              // If both have a number, sort numerically
              if (a.videoNumber != null && b.videoNumber != null) {
                return a.videoNumber!.compareTo(b.videoNumber!);
              }
              // If 'a' has a number and 'b' doesn't, 'a' comes first
              else if (a.videoNumber != null && b.videoNumber == null) {
                return -1;
              }
              // If 'b' has a number and 'a' doesn't, 'b' comes first
              else if (a.videoNumber == null && b.videoNumber != null) {
                return 1;
              }
              // If neither has a number, sort by title as a fallback
              else {
                return a.title.compareTo(b.title);
              }
            });

            return ListView.builder(
              itemCount: sortedVideos.length,
              itemBuilder: (context, index) {
                final video = sortedVideos[index];
                return ListTile(
                  leading: Text(
                    video.videoNumber != null ? '${video.videoNumber}.' : '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  title: Text(video.title),
                    subtitle: Text('Duration: ${video.duration}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showAddEditVideoDialog(context, video: video),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Video'),
                                content: const Text('Are you sure you want to delete this Video?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              context.read<VideosBloc>().add(DeleteVideo(
                                courseId: courseId,
                                subjectId: subjectId,
                                chapterId: chapterId,
                                videoId: video.id,
                              ));
                            }
                          },
                        ),
                      ],
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
    final numberController = TextEditingController(text: isEditing && video.videoNumber != null ? video.videoNumber.toString() : '');
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
                  TextFormField(
                    controller: numberController,
                    decoration: const InputDecoration(labelText: 'Video Number'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a number';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
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
                  final int videoNumber = int.parse(numberController.text);
                  if (isEditing) {
                    videosBloc.add(UpdateVideo(
                      courseId: courseId,
                      subjectId: subjectId,
                      chapterId: chapterId,
                      id: video.id,
                      newTitle: titleController.text,
                      newVideoId: videoIdController.text,
                      newDuration: durationController.text,
                      newVideoNumber: videoNumber,
                    ));
                  } else {
                    videosBloc.add(AddVideo(
                      courseId: courseId,
                      subjectId: subjectId,
                      chapterId: chapterId,
                      title: titleController.text,
                      videoId: videoIdController.text,
                      duration: durationController.text,
                      videoNumber: videoNumber,
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