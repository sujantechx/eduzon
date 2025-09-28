// lib/logic/content/content_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/content_repository.dart';
import 'content_state.dart';


// Manages the business logic for all content operations (Subjects, Chapters, etc.).
class ContentCubit extends Cubit<ContentState> {
  final ContentRepository _contentRepository;

  ContentCubit({required ContentRepository contentRepository})
      : _contentRepository = contentRepository,
        super(ContentInitial());

  //=========== Subject Methods ===========

  /// Calls the repository to add a new subject.
  Future<void> addSubject({required String title}) async {
    // 1. Validate the input to ensure it's not empty.
    if (title.isEmpty) {
      emit(const ContentError('Title cannot be empty.'));
      return;
    }
    // 2. Tell the UI that an operation is in progress.
    emit(ContentLoading());
    try {
      // 3. Call the repository to perform the database write.
      await _contentRepository.addSubject(title: title);
      // 4. Tell the UI the operation was successful.
      emit(const ContentSuccess('Subject added successfully!'));
    } catch (e) {
      // 5. If an error occurs, tell the UI about it.
      emit(ContentError(e.toString()));
    }
  }

  /// Calls the repository to update a subject.
  Future<void> updateSubject({required String subjectId, required String newTitle}) async {
    if (newTitle.isEmpty) {
      emit(const ContentError('Title cannot be empty.'));
      return;
    }
    emit(ContentLoading());
    try {
      await _contentRepository.updateSubject(subjectId: subjectId, newTitle: newTitle);
      emit(const ContentSuccess('Subject updated successfully!'));
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }

  /// Calls the repository to delete a subject.
  Future<void> deleteSubject({required String subjectId}) async {
    emit(ContentLoading());
    try {
      await _contentRepository.deleteSubject(subjectId: subjectId);
      emit(const ContentSuccess('Subject deleted successfully!'));
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }

  //=========== Chapter Methods ===========

  /// Calls the repository to add a new chapter.
  Future<void> addChapter({required String subjectId, required String title}) async {
    if (title.isEmpty) {
      emit(const ContentError('Title cannot be empty.'));
      return;
    }
    emit(ContentLoading());
    try {
      await _contentRepository.addChapter(subjectId: subjectId, title: title);
      emit(const ContentSuccess('Chapter added successfully!'));
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }

  /// Calls the repository to update a chapter.
  Future<void> updateChapter({required String subjectId, required String chapterId, required String newTitle}) async {
    if (newTitle.isEmpty) {
      emit(const ContentError('Title cannot be empty.'));
      return;
    }
    emit(ContentLoading());
    try {
      await _contentRepository.updateChapter(subjectId: subjectId, chapterId: chapterId, newTitle: newTitle);
      emit(const ContentSuccess('Chapter updated successfully!'));
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }

  /// Calls the repository to delete a chapter.
  Future<void> deleteChapter({required String subjectId, required String chapterId}) async {
    emit(ContentLoading());
    try {
      await _contentRepository.deleteChapter(subjectId: subjectId, chapterId: chapterId);
      emit(const ContentSuccess('Chapter deleted successfully!'));
    } catch (e) {
      emit(ContentError(e.toString()));
    }
  }
}

/// after lunch update


