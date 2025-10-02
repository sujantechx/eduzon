import 'package:eduzon/logic/subject/subject_event.dart';
import 'package:eduzon/logic/subject/subject_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/admin_repository.dart';

class SubjectsBloc extends Bloc<SubjectEvent, SubjectState> {
  final AdminRepository _adminRepository;

  SubjectsBloc(this._adminRepository) : super(SubjectsInitial()) {
    on<LoadSubjects>(_onLoadSubjects);
    on<AddSubject>(_onAddSubject);
    on<UpdateSubject>(_onUpdateSubject);
    on<DeleteSubject>(_onDeleteSubject);
  }

  void _onLoadSubjects(LoadSubjects event, Emitter<SubjectState> emit) async {
    emit(SubjectsLoading());
    try {
      final subjects = await _adminRepository.getSubjects(courseId: event.courseId);
      emit(SubjectsLoaded(subjects));
    } catch (e) {
      emit(SubjectsError(e.toString()));
    }
  }

  void _onAddSubject(AddSubject event, Emitter<SubjectState> emit) async {
    emit(SubjectsLoading());
    try {
      await _adminRepository.addSubject(
        courseId: event.courseId,
        title: event.title,
        description: event.description,
        subjectNumber: event.subjectNumber,
      );
      // After adding, reload the subjects to show the new one
      add(LoadSubjects(courseId: event.courseId));
    } catch (e) {
      emit(SubjectsError(e.toString()));
    }
  }

  void _onUpdateSubject(UpdateSubject event, Emitter<SubjectState> emit) async {
    emit(SubjectsLoading());
    try {
      await _adminRepository.updateSubject(
        courseId: event.courseId,
        subjectId: event.subjectId,
        subjectNumber: event.newSubjectNumber,
        data: {'title': event.newTitle, 'description': event.newDescription},
      );
      // After updating, reload the list
      add(LoadSubjects(courseId: event.courseId));
    } catch (e) {
      emit(SubjectsError(e.toString()));
    }
  }

  void _onDeleteSubject(DeleteSubject event, Emitter<SubjectState> emit) async {
    try {
      await _adminRepository.deleteSubject(
        courseId: event.courseId,
        subjectId: event.subjectId,
      );
      // After deleting, reload the list
      add(LoadSubjects(courseId: event.courseId));
    } catch (e) {
      emit(SubjectsError(e.toString()));
    }
  }
}