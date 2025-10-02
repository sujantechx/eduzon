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
  final AuthCubit _authCubit; // Depend on AuthCubit to get user info
  Timer? _timer;
  final int _questionTimeLimit = 30; // 30 seconds per question

  // Class-level variables to store quiz context
  String? _currentChapterId;
  String? _currentCourseId;
  String? _currentSubjectId;

  // Constructor with Dependency Injection
  QuizCubit(this._testRepository, this._authCubit) : super(QuizInitial());

  /// Loads all questions for a specific chapter.
  /// First, it checks for an existing result to prevent re-taking the quiz.
  Future<void> loadQuestions({
    required String courseId,
    required String subjectId,
    required String chapterId,
  }) async {
    try {
      emit(QuizLoading());

      // Store the context IDs for later use in submitQuiz
      _currentCourseId = courseId;
      _currentSubjectId = subjectId;
      _currentChapterId = chapterId;

      // Get user details to check for existing results
      final authState = _authCubit.state;
      if (authState is! Authenticated) {
        emit(const QuizError(message: 'User not authenticated.'));
        return;
      }
      final userId = authState.userModel.uid;

      // Check if a result already exists for this user and chapter
      final existingResult = await _testRepository.getResultForUserAndChapter(
        userId: userId,
        chapterId: chapterId,
      );

      // If a result exists, show it immediately and bypass the quiz
      if (existingResult != null) {
        final questions = await _testRepository.getQuestions(
          courseId: courseId,
          subjectId: subjectId,
          chapterId: chapterId,
        );
        emit(QuizCompleted(
          result: existingResult,
          questions: questions, // Pass questions for the review screen
        ));
        return;
      }

      // If no result exists, proceed to load questions and start the quiz
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

  /// Calculates the final score and submits the result to the repository.
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

      // Create the result model with dynamic data
      final result = ResultModel(
        id: '', // Firestore will generate the document ID
        userId: userId,
        userName: userName,
        chapterId: _currentChapterId!,
        totalQuestions: currentState.questions.length,
        correctAnswers: correctAnswers,
        answers: answerDetails,
      );

      // Save the result to Firestore
      try {
        await _testRepository.submitResult(result: result);
      } catch (e) {
        emit(QuizError(message: 'Failed to submit result: ${e.toString()}'));
        return;
      }

      // Transition to QuizCompleted state with all necessary data
      emit(QuizCompleted(result: result, questions: currentState.questions));
    }
  }

  /// Resets the quiz to its initial state for a retest.
  void retest({
    required String courseId,
    required String subjectId,
    required String chapterId,
  }) {
    emit(QuizInitial());
    loadQuestions(
      courseId: courseId,
      subjectId: subjectId,
      chapterId: chapterId,
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}