// lib/logic/chapter/chapters_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/chapter_model.dart';
import '../../data/repositories/admin_repository.dart';
import 'chapters_event.dart';
import 'chapters_state.dart';


class ChaptersBloc extends Bloc<ChaptersEvent, ChaptersState> {
  final AdminRepository _adminRepository;

  ChaptersBloc(this._adminRepository) : super(ChaptersInitial()) {
    on<LoadChapters>(_onLoadChapters);
    // Register the new event handlers
    on<AddChapter>(_onAddChapter);
    on<UpdateChapter>(_onUpdateChapter);
  }

  void _onLoadChapters(LoadChapters event, Emitter<ChaptersState> emit) async {
    emit(ChaptersLoading());
    try {
      final chapters = await _adminRepository.getChapters(
        courseId: event.courseId,
        subjectId: event.subjectId,
      );
      emit(ChaptersLoaded(chapters));
    } catch (e) {
      emit(ChaptersError(e.toString()));
    }
  }

  // Add this handler method
  void _onAddChapter(AddChapter event, Emitter<ChaptersState> emit) async {
    try {
      await _adminRepository.addChapter(
        courseId: event.courseId,
        subjectId: event.subjectId,
        title: event.title,
      );
      // After adding, reload the chapters to show the new one
      add(LoadChapters(courseId: event.courseId, subjectId: event.subjectId));
    } catch (e) {
      emit(ChaptersError(e.toString()));
    }
  }

  // Add this handler method
  void _onUpdateChapter(UpdateChapter event, Emitter<ChaptersState> emit) async {
    try {
      await _adminRepository.updateChapter(
        courseId: event.courseId,
        subjectId: event.subjectId,
        chapterId: event.chapterId,
        data: {'title': event.newTitle},
      );
      // After updating, reload the list
      add(LoadChapters(courseId: event.courseId, subjectId: event.subjectId));
    } catch (e) {
      emit(ChaptersError(e.toString()));
    }
  }
}