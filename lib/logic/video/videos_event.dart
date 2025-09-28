// lib/logic/video/videos_event.dart

import 'package:equatable/equatable.dart';

abstract class VideosEvent extends Equatable {
  const VideosEvent();
  @override
  List<Object> get props => [];
}

class LoadVideos extends VideosEvent {
  final String courseId;
  final String subjectId;
  final String chapterId;
  const LoadVideos({required this.courseId, required this.subjectId, required this.chapterId});
  @override
  List<Object> get props => [courseId, subjectId, chapterId];
}

// Add this event
class AddVideo extends VideosEvent {
  final String courseId;
  final String subjectId;
  final String chapterId;
  final String title;
  final String videoId; // YouTube ID
  final String duration;

  const AddVideo({
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
    required this.title,
    required this.videoId,
    required this.duration,
  });

  @override
  List<Object> get props => [courseId, subjectId, chapterId, title, videoId, duration];
}

// Add this event
class UpdateVideo extends VideosEvent {
  final String courseId;
  final String subjectId;
  final String chapterId;
  final String id; // Document ID of the video to update
  final String newTitle;
  final String newVideoId;
  final String newDuration;

  const UpdateVideo({
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
    required this.id,
    required this.newTitle,
    required this.newVideoId,
    required this.newDuration,
  });

  @override
  List<Object> get props => [courseId, subjectId, chapterId, id, newTitle, newVideoId, newDuration];
}