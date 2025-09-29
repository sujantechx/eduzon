// lib/logic/admin/courses/admin_courses_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/admin_repository.dart';
import 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {
  final AdminRepository _adminRepository;

  CoursesCubit({required AdminRepository adminRepository})
      : _adminRepository = adminRepository,
        super(AdminCoursesInitial());

  /// Fetches the list of all courses from the repository.
  Future<void> loadCourses() async {
    emit(AdminCoursesLoading());
    try {
      final courses = await _adminRepository.getCourses();
      emit(AdminCoursesLoaded(courses));
    } catch (e) {
      emit(AdminCoursesError(e.toString()));
    }
  }

  /// Adds a new course and then reloads the list to show the update.
  Future<void> addCourse({required String title, required String description}) async {
    emit(AdminCoursesLoading());
    try {
      await _adminRepository.addCourse(title: title, description: description);
      emit(const AdminCoursesSuccess('Course added successfully!'));
      loadCourses(); // Refresh the list
    } catch (e) {
      emit(AdminCoursesError(e.toString()));
    }
  }

  /// Updates an existing course and then reloads the list.
  Future<void> updateCourse({required String courseId, required Map<String, dynamic> data}) async {
    emit(AdminCoursesLoading());
    try {
      await _adminRepository.updateCourse(courseId: courseId, data: data);
      emit(const AdminCoursesSuccess('Course updated successfully!'));
      loadCourses(); // Refresh the list
    } catch (e) {
      emit(AdminCoursesError(e.toString()));
    }
  }

  /// Deletes a course and then reloads the list.
  Future<void> deleteCourse({required String courseId}) async {
    emit(AdminCoursesLoading());
    try {
      await _adminRepository.deleteCourse(courseId: courseId);
      emit(const AdminCoursesSuccess('Course deleted successfully!'));
      loadCourses(); // Refresh the list
    } catch (e) {
      emit(AdminCoursesError(e.toString()));
    }
  }
}