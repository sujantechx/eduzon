// lib/logic/quiz/quiz_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:eduzon/data/models/result_model.dart';
import 'package:eduzon/data/repositories/admin_repository.dart';
import 'package:eduzon/logic/auth/auth_bloc.dart';
import 'package:eduzon/logic/auth/auth_state.dart';
import 'package:eduzon/logic/test/test_state.dart';

// Cubit
class QuizCubit extends Cubit<QuizState> {
  final AdminRepository _testRepository;
  final AuthCubit _authCubit;
  Timer? _timer;
  final int _questionTimeLimit = 30;

  // Class-level variables to store quiz context
  String? _currentChapterId;
  String? _currentCourseId;
  String? _currentSubjectId;
  ResultModel? _existingResult; // To store the existing result for update logic

  // Constructor with Dependency Injection
  QuizCubit(this._testRepository, this._authCubit) : super(QuizInitial());

  /// Loads all questions for a specific chapter.
  /// First, it checks for an existing result to prevent re-taking the quiz,
  /// unless a retest is forced.
  Future<void> loadQuestions({
    required String courseId,
    required String subjectId,
    required String chapterId,
    bool forceRetest = false, // ✅ Added forceRetest parameter
  }) async {
    try {
      emit(QuizLoading());

      // Store the context IDs for later use in submitQuiz
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

      // If a result exists and it's NOT a forced retest, show it immediately.
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

      // If no result exists or it's a forced retest, proceed to load questions.
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

  /// Calculates the final score and submits or updates the result to the repository.
  Future<void> submitQuiz() async {
    if (state is QuizLoaded) {
      _timer?.cancel();
      final currentState = state as QuizLoaded;
      int correctAnswers = 0;
      final List<Map<String, dynamic>> answerDetails = [];

      // Add null safety checks for the stored variables before use
      if (_currentChapterId == null || _currentCourseId == null || _currentSubjectId == null) {
        emit(const QuizError(message: 'Quiz data is missing. Please restart the quiz.'));
        return;
      }

      // Aggregate user answers and correct answers
      for (var question in currentState.questions) {
        final userAnswer = currentState.userAnswers[question.id];
        final isCorrect = userAnswer == question.correctAnswerIndex;
        if (isCorrect) {
          correctAnswers++;
        }
        answerDetails.add({
          'questionId': question.id,
          'userAnswer': userAnswer,
          'correctAnswer': question.correctAnswerIndex,
        });
      }

      // Get user details from AuthCubit
      final authState = _authCubit.state;
      String userId = '';
      String userName = 'Guest';
      if (authState is Authenticated) {
        userId = authState.userModel.uid;
        userName = authState.userModel.name;
      }

      // Create the result model with dynamic data.
      // Use the existing result's ID for updates, or an empty string for new documents.
      final result = ResultModel(
        id: _existingResult?.id ?? '', // Use existing ID if available
        userId: userId,
        userName: userName,
        chapterId: _currentChapterId!,
        totalQuestions: currentState.questions.length,
        correctAnswers: correctAnswers,
        answers: answerDetails,
      );

      // Save or update the result to Firestore
      try {
        if (_existingResult != null) {
          // If a previous result exists, update the document.
          await _testRepository.updateResult(result: result);
        } else {
          // If no previous result exists, submit a new one.
          await _testRepository.submitResult(result: result);
        }
      } catch (e) {
        emit(QuizError(message: 'Failed to submit result: ${e.toString()}'));
        return;
      }

      // Transition to QuizCompleted state with all necessary data
      emit(QuizCompleted(result: result, questions: currentState.questions));
    }
  }

  /// ✅ Corrected retest method. It now uses the stored IDs and the forceRetest flag.
  void retest() {
    if (_currentCourseId != null && _currentSubjectId != null && _currentChapterId != null) {
      emit(QuizInitial()); // Reset the state to show a loading indicator.
      loadQuestions(
        courseId: _currentCourseId!,
        subjectId: _currentSubjectId!,
        chapterId: _currentChapterId!,
        forceRetest: true, // Force a retest
      );
    } else {
      emit(const QuizError(message: 'Quiz data is missing. Cannot retest.'));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}