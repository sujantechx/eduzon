// lib/logic/admin/admin_cubit.dart or lib/logic/test/test_cubit.dart
import 'dart:developer' as developer;

import 'package:eduzon/logic/test/question_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/question_model.dart';
import '../../data/repositories/admin_repository.dart';



// Cubit to manage state
class QuestionCubit extends Cubit<QuestionState> {
  final AdminRepository _adminRepository;

  QuestionCubit(this._adminRepository) : super(QuestionInitial());

  Future<void> fetchQuestions({
    required String courseId,
    required String subjectId,
    required String chapterId,
  }) async {
    try {
      emit(QuestionLoading());
      final questions = await _adminRepository.getQuestions(
        courseId: courseId,
        subjectId: subjectId,
        chapterId: chapterId,
      );
      emit(QuestionsLoaded(questions));
    } catch (e) {
      emit(QuestionError('Failed to load questions: ${e.toString()}'));
    }
  }
      // ✅ CORRECTED: Add new parameters for type and imageUrl.

  Future<void> addQuestion({
    required String courseId,
    required String subjectId,
    required String chapterId,
    required String type, // 'text' or 'image'
    String? text, // Now nullable
    String? imageUrl, // Now nullable
    required List<String> options,
    required int correctAnswerIndex,
    required int questionNumber,
  }) async {
    try {
      emit(QuestionLoading());
      final newQuestion = QuestionModel(
        id: '', // Firestore will generate an ID
        type: type,
        text: text, // Pass the nullable text
        imageUrl: imageUrl, // Pass the nullable imageUrl
        options: options,
        correctAnswerIndex: correctAnswerIndex,
      );
      await _adminRepository.addQuestion(
        courseId: courseId,
        subjectId: subjectId,
        chapterId: chapterId,
        question: newQuestion, questionNumber: questionNumber ,
      );
      // Re-fetch to update the UI
      await fetchQuestions(
        courseId: courseId,
        subjectId: subjectId,
        chapterId: chapterId,
      );
    } catch (e) {
      developer.log('Error adding question: $e');
      emit(QuestionError('Failed to add question: ${e.toString()}'));
    }
  }
/*      Future<void> addQuestion({
        required String courseId,
        required String subjectId,
        required String chapterId,
        required String type,
        String? text,
        String? imageUrl,
        required List<String> options,
        required int correctAnswerIndex,
      }) async {
        try {
          emit(QuestionLoading());
          final newQuestion = QuestionModel(
            id: '', // Firestore will generate an ID
            type: type,
            text: text,
            imageUrl: imageUrl,
            options: options,
            correctAnswerIndex: correctAnswerIndex,
          );
          await _adminRepository.addQuestion(
            courseId: courseId,
            subjectId: subjectId,
            chapterId: chapterId,
            question: newQuestion,
          );
          // Re-fetch to update UI
          await fetchQuestions(
            courseId: courseId,
            subjectId: subjectId,
            chapterId: chapterId,
          );
        } catch (e) {
          developer.log('Error adding question: $e');
          emit(QuestionError('Failed to add question: ${e.toString()}'));
        }
      }*/

      // ✅ CORRECTED: Add new parameters for type and imageUrl.
      Future<void> updateQuestion({
        required String courseId,
        required String subjectId,
        required String chapterId,
        required String id,
        required String type,
        String? newText,
        String? newImageUrl,
        required List<String> newOptions,
        required int newCorrectAnswerIndex,
        required int questionNumber,
      }) async {
        try {
          emit(QuestionLoading());
          final updatedQuestion = QuestionModel(
            id: id,
            type: type,
            text: newText,
            imageUrl: newImageUrl,
            options: newOptions,
            correctAnswerIndex: newCorrectAnswerIndex,
          );
          await _adminRepository.updateQuestion(
            courseId: courseId,
            subjectId: subjectId,
            chapterId: chapterId,
            question: updatedQuestion,
            questionNumber: questionNumber,
          );
          // Re-fetch to update UI
          await fetchQuestions(
            courseId: courseId,
            subjectId: subjectId,
            chapterId: chapterId,
          );
        } catch (e) {
          developer.log('Error updating question: $e');
          emit(QuestionError('Failed to update question: ${e.toString()}'));
        }
      }

  Future<void> deleteQuestion({
    required String courseId,
    required String subjectId,
    required String chapterId,
    required String questionId,
  }) async {
    try {
      emit(QuestionLoading());
      await _adminRepository.deleteQuestion(
        courseId: courseId,
        subjectId: subjectId,
        chapterId: chapterId,
        questionId: questionId,
      );
      // Re-fetch to update UI
      await fetchQuestions(
        courseId: courseId,
        subjectId: subjectId,
        chapterId: chapterId,
      );
    } catch (e) {
      emit(QuestionError('Failed to delete question: ${e.toString()}'));
    }
  }
}

// Events for the Bloc
abstract class QuestionEvent {}
class FetchQuestions extends QuestionEvent {
  final String courseId;
  final String subjectId;
  final String chapterId;
  FetchQuestions(this.courseId, this.subjectId, this.chapterId);
}
class AddQuestion extends QuestionEvent {
  final String courseId;
  final String subjectId;
  final String chapterId;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  AddQuestion({
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });
}
class UpdateQuestion extends QuestionEvent {
  final String courseId;
  final String subjectId;
  final String chapterId;
  final String id;
  final String newText;
  final List<String> newOptions;
  final int newCorrectAnswerIndex;
  UpdateQuestion({
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
    required this.id,
    required this.newText,
    required this.newOptions,
    required this.newCorrectAnswerIndex,
  });
}
class DeleteQuestion extends QuestionEvent {
  final String courseId;
  final String subjectId;
  final String chapterId;
  final String id;
  DeleteQuestion({
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
    required this.id,
  });
}

// Bloc implementation using Events
// This is an alternative to the Cubit above.
class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final AdminRepository _adminRepository;

  QuestionBloc(this._adminRepository) : super(QuestionInitial()) {
    on<FetchQuestions>((event, emit) async {
      // Logic for fetching questions (same as Cubit)
    });
    on<AddQuestion>((event, emit) async {
      // Logic for adding questions
    });
    // Add other event handlers for Update and Delete
  }
}