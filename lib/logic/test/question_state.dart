// lib/logic/admin/admin_cubit.dart or lib/logic/test/test_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../data/models/question_model.dart';
import '../../data/repositories/admin_repository.dart';

// States for question management
abstract class QuestionState {}
class QuestionInitial extends QuestionState {}
class QuestionLoading extends QuestionState {}
class QuestionsLoaded extends QuestionState {
  final List<QuestionModel> questions;
  QuestionsLoaded(this.questions);
}
class QuestionError extends QuestionState {
  final String message;
  QuestionError(this.message);
}