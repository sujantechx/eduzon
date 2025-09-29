// lib/presentation/blocs/subjects/subjects_state.dart
import 'package:equatable/equatable.dart';

import '../../data/models/subject_model.dart';

abstract class SubjectState extends Equatable {
  const SubjectState();

  @override
  List<Object> get props => [];
}

/// The initial state before any event is dispatched.
class SubjectsInitial extends SubjectState {}

/// State while the subjects are being fetched from the repository.
class SubjectsLoading extends SubjectState {}

/// State when the subjects have been successfully loaded.
class SubjectsLoaded extends SubjectState {
  final List<SubjectModel> subjects;
  const SubjectsLoaded(this.subjects);
  @override
  List<Object> get props => [subjects];
}

/// State when an error occurs during an operation.
class SubjectsError extends SubjectState {
  final String message;
  const SubjectsError(this.message);
  @override
  List<Object> get props => [message];
}