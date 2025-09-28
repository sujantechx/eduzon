// lib/logic/chapter/chapters_event.dart

import 'package:equatable/equatable.dart';

abstract class ChaptersEvent extends Equatable {
  const ChaptersEvent();
  @override
  List<Object> get props => [];
}

class LoadChapters extends ChaptersEvent {
  final String courseId;
  final String subjectId;
  const LoadChapters({required this.courseId, required this.subjectId});
  @override
  List<Object> get props => [courseId, subjectId];
}

// Add this event
class AddChapter extends ChaptersEvent {
  final String courseId;
  final String subjectId;
  final String title;

  const AddChapter({
    required this.courseId,
    required this.subjectId,
    required this.title,
  });

  @override
  List<Object> get props => [courseId, subjectId, title];
}

// Add this event
class UpdateChapter extends ChaptersEvent {
  final String courseId;
  final String subjectId;
  final String chapterId;
  final String newTitle;

  const UpdateChapter({
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
    required this.newTitle,
  });

  @override
  List<Object> get props => [courseId, subjectId, chapterId, newTitle];
}