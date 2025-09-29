// lib/presentation/blocs/subjects/subjects_event.dart


import 'package:equatable/equatable.dart';
abstract class SubjectEvent extends Equatable {
  const SubjectEvent();

  @override
  List<Object> get props => [];
}

/// Event to load all subjects for a specific course.
class LoadSubjects extends SubjectEvent {
  final String courseId;
  const LoadSubjects({required this.courseId});
  @override
  List<Object> get props => [courseId];
}

/// Event to add a new subject.
class AddSubject extends SubjectEvent {
  final String courseId;
  final String title;
  final String description;

  const AddSubject({
    required this.courseId,
    required this.title,
    required this.description,
  });

  @override
  List<Object> get props => [courseId, title, description];
}

/// Event to update an existing subject.
class UpdateSubject extends SubjectEvent {
  final String courseId;
  final String subjectId;
  final String newTitle;
  final String newDescription;

  const UpdateSubject({
    required this.courseId,
    required this.subjectId,
    required this.newTitle,
    required this.newDescription,
  });

  @override
  List<Object> get props => [courseId, subjectId, newTitle, newDescription];
}

/// Event to delete a subject.
class DeleteSubject extends SubjectEvent {
  final String courseId;
  final String subjectId;

  const DeleteSubject({required this.courseId, required this.subjectId});

  @override
  List<Object> get props => [courseId, subjectId];
}