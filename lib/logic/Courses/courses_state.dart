// lib/logic/admin/courses/admin_courses_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/courses_moddel.dart';

abstract class CoursesState extends Equatable {
  const CoursesState();
  @override
  List<Object> get props => [];
}

/// The initial state before any action has been taken.
class AdminCoursesInitial extends CoursesState {}

/// The state when data is being fetched or an operation is in progress.
class AdminCoursesLoading extends CoursesState {}

/// The state when the list of courses has been successfully loaded.
class AdminCoursesLoaded extends CoursesState {
  final List<CoursesModel> courses;
  const AdminCoursesLoaded(this.courses);
  @override
  List<Object> get props => [courses];
}

/// A temporary state to indicate a successful operation (add, update, delete).
class AdminCoursesSuccess extends CoursesState {
  final String message;
  const AdminCoursesSuccess(this.message);
  @override
  List<Object> get props => [message];
}

/// The state when an error has occurred.
class AdminCoursesError extends CoursesState {
  final String message;
  const AdminCoursesError(this.message);
  @override
  List<Object> get props => [message];
}