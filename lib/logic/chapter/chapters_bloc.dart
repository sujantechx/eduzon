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
    on<DeleteChapter>(_onDeleteChapter);
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
        chapterNumber: event.chapterNumber,
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
      // 💡 Create a single map with all fields to be updated
      final Map<String, dynamic> updateData = {
        'title': event.newTitle,
        'chapterNumber': event.newChapterNumber,
      };

      await _adminRepository.updateChapter(
        courseId: event.courseId,
        subjectId: event.subjectId,
        chapterId: event.chapterId,
        data: updateData, // Pass the combined map
      );
      // After updating, reload the list
      add(LoadChapters(courseId: event.courseId, subjectId: event.subjectId,));
    } catch (e) {
      emit(ChaptersError(e.toString()));
    }
  }
  // deferent way to update chapter number

  /*void _onUpdateChapter(UpdateChapter event, Emitter<ChaptersState> emit) async {
    try {
      await _adminRepository.updateChapter(
        courseId: event.courseId,
        subjectId: event.subjectId,
        chapterId: event.chapterId,
        chapterNumber: event.newChapterNumber,
        data: {'title': event.newTitle},
      );
      // After updating, reload the list
      add(LoadChapters(courseId: event.courseId, subjectId: event.subjectId,));
    } catch (e) {
      emit(ChaptersError(e.toString()));
    }
  }*/
  // Add the _onDeleteChapter method if needed
void _onDeleteChapter(DeleteChapter event, Emitter<ChaptersState> emit) async {
    try {
      await _adminRepository.deleteChapter(
        courseId: event.courseId,
        subjectId: event.subjectId,
        chapterId: event.chapterId,
      );
      // After deleting, reload the list
      add(LoadChapters(courseId: event.courseId, subjectId: event.subjectId));
    } catch (e) {
      emit(ChaptersError(e.toString()));
    }
  }

}