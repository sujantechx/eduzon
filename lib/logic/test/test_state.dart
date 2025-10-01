
// States
import 'package:equatable/equatable.dart';

import '../../data/models/question_model.dart';
import '../../data/models/result_model.dart';

// States
abstract class QuizState extends Equatable {
  const QuizState();
}

class QuizInitial extends QuizState {
  @override
  List<Object?> get props => [];
}

class QuizLoading extends QuizState {
  @override
  List<Object?> get props => [];
}

class QuizLoaded extends QuizState {
  final List<QuestionModel> questions;
  final int currentQuestionIndex;
  final Map<String, int?> userAnswers;
  final int timeLeft; // Time for the current question

  const QuizLoaded({
    required this.questions,
    required this.currentQuestionIndex,
    required this.userAnswers,
    required this.timeLeft,
  });

  @override
  List<Object?> get props => [
    questions,
    currentQuestionIndex,
    userAnswers,
    timeLeft,
  ];

  QuizLoaded copyWith({
    int? currentQuestionIndex,
    Map<String, int?>? userAnswers,
    int? timeLeft,
  }) {
    return QuizLoaded(
      questions: questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      userAnswers: userAnswers ?? this.userAnswers,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }
}

// In lib/logic/quiz/quiz_cubit.dart
class QuizCompleted extends QuizState {
  final ResultModel result;
  final List<QuestionModel> questions; // ✅ Add the questions list

  const QuizCompleted({
    required this.result,
    required this.questions, // ✅ Update the constructor
  });

  @override
  List<Object?> get props => [result, questions];
}
class QuizError extends QuizState {
  final String message;

  const QuizError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
