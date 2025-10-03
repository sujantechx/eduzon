// lib/logic/test/quiz_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:eduzon/data/models/question_model.dart';
import 'package:eduzon/data/models/result_model.dart';
import 'package:eduzon/data/repositories/admin_repository.dart';
import 'package:eduzon/logic/auth/auth_bloc.dart';
import 'package:eduzon/logic/auth/auth_state.dart';
import 'package:eduzon/logic/test/test_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final AdminRepository _testRepository;
  final AuthCubit _authCubit;
  Timer? _timer;
  final int _questionTimeLimit = 30;

  String? _currentChapterId;
  String? _currentCourseId;
  String? _currentSubjectId;
  ResultModel? _existingResult; // Stores the existing result to decide whether to update or create.

  QuizCubit(this._testRepository, this._authCubit) : super(QuizInitial());

  /// Loads questions and determines if it's a new quiz or a retest.
  Future<void> loadQuestions({
    required String courseId,
    required String subjectId,
    required String chapterId,
    bool forceRetest = false, // ✅ Flag to force a retest
  }) async {
    try {
      emit(QuizLoading());
      _currentCourseId = courseId;
      _currentSubjectId = subjectId;
      _currentChapterId = chapterId;

      final authState = _authCubit.state;
      if (authState is! Authenticated) {
        emit(const QuizError(message: 'User not authenticated.'));
        return;
      }
      final userId = authState.userModel.uid;

      _existingResult = await _testRepository.getResultForUserAndChapter(
        userId: userId,
        chapterId: chapterId,
      );

      // If a result exists and it's not a retest, show the result screen.
      if (_existingResult != null && !forceRetest) {
        final questions = await _testRepository.getQuestions(
          courseId: courseId,
          subjectId: subjectId,
          chapterId: chapterId,
        );
        emit(QuizCompleted(
          result: _existingResult!,
          questions: questions,
        ));
        return;
      }

      // Load questions if it's a new quiz or a forced retest.
      final questions = await _testRepository.getQuestions(
        courseId: courseId,
        subjectId: subjectId,
        chapterId: chapterId,
      );
      if (questions.isEmpty) {
        emit(const QuizError(message: 'No questions available.'));
      } else {
        emit(QuizLoaded(
          questions: questions,
          currentQuestionIndex: 0,
          userAnswers: {},
          timeLeft: _questionTimeLimit,
        ));
        _startTimer();
      }
    } catch (e) {
      emit(QuizError(message: 'Failed to load quiz: ${e.toString()}'));
    }
  }
  /// Starts the timer for the current question.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is QuizLoaded) {
        final currentState = state as QuizLoaded;
        if (currentState.timeLeft > 0) {
          emit(currentState.copyWith(timeLeft: currentState.timeLeft - 1));
        } else {
          // Time's up, automatically go to the next question.
          nextQuestion();
        }
      }
    });
  }

  /// Records the user's selected answer for the current question.
  void selectAnswer(int answerIndex) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final currentQuestion = currentState.questions[currentState.currentQuestionIndex];
      final updatedAnswers = Map<String, int?>.from(currentState.userAnswers);
      updatedAnswers[currentQuestion.id] = answerIndex;

      emit(currentState.copyWith(userAnswers: updatedAnswers));
    }
  }

  /// Advances to the next question or submits the quiz if all questions are answered.
  void nextQuestion() {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      if (currentState.currentQuestionIndex < currentState.questions.length - 1) {
        emit(currentState.copyWith(
          currentQuestionIndex: currentState.currentQuestionIndex + 1,
          timeLeft: _questionTimeLimit, // Reset timer for the next question
        ));
        _startTimer();
      } else {
        submitQuiz();
      }
    }
  }
  /// Calculates score and submits/updates the result.
  Future<void> submitQuiz() async {
    if (state is QuizLoaded) {
      _timer?.cancel();
      final currentState = state as QuizLoaded;
      int correctAnswers = 0;
      final List<Map<String, dynamic>> answerDetails = [];

      final authState = _authCubit.state;
      String userId = '';
      String userName = 'Guest';
      if (authState is Authenticated) {
        userId = authState.userModel.uid;
        userName = authState.userModel.name;
      }

      for (var question in currentState.questions) {
        final userAnswer = currentState.userAnswers[question.id];
        final isCorrect = userAnswer == question.correctAnswerIndex;
        if (isCorrect) correctAnswers++;
        answerDetails.add({
          'questionId': question.id,
          'userAnswer': userAnswer,
          'correctAnswer': question.correctAnswerIndex,
        });
      }

      final result = ResultModel(
        id: _existingResult?.id ?? '', // Re-use ID for updates, otherwise empty
        userId: userId,
        userName: userName,
        chapterId: _currentChapterId!,
        totalQuestions: currentState.questions.length,
        correctAnswers: correctAnswers,
        answers: answerDetails,
      );

      try {
        // ✅ The key logic for retests: decide to update or submit
        if (_existingResult != null) {
          await _testRepository.updateResult(result: result);
        } else {
          await _testRepository.submitResult(result: result);
        }
      } catch (e) {
        emit(QuizError(message: 'Failed to submit result: ${e.toString()}'));
        return;
      }
      emit(QuizCompleted(result: result, questions: currentState.questions));
    }
  }

  /// ✅ Triggers a retest by calling loadQuestions with the forceRetest flag.
  void retest() {
    if (_currentCourseId != null && _currentSubjectId != null && _currentChapterId != null) {
      emit(QuizInitial());
      loadQuestions(
        courseId: _currentCourseId!,
        subjectId: _currentSubjectId!,
        chapterId: _currentChapterId!,
        forceRetest: true, // Force a retest
      );
    } else {
      emit(const QuizError(message: 'Quiz data is missing.'));
    }
  }

  // ... (rest of the cubit methods) ...

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}