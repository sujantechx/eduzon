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
  final int chapterNumber; // Add this field

  const AddChapter({
    required this.courseId,
    required this.subjectId,
    required this.title,
    required this.chapterNumber,
  });

  @override
  List<Object> get props => [courseId, subjectId, title, chapterNumber];
}

// Add this event
class UpdateChapter extends ChaptersEvent {
  final String courseId;
  final String subjectId;
  final String chapterId;
  final String newTitle;
  final int newChapterNumber;

  const UpdateChapter({
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
    required this.newTitle,
    required this.newChapterNumber,
  });

  @override
  List<Object> get props => [courseId, subjectId, chapterId, newTitle, newChapterNumber];
}
class DeleteChapter extends ChaptersEvent {
  final String courseId;
  final String subjectId;
  final String chapterId;
  const DeleteChapter({
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
  });
  @override
  List<Object> get props => [courseId, subjectId, chapterId];
}