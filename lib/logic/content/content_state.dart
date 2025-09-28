// lib/logic/content/content_state.dart

import 'package:equatable/equatable.dart';

// Defines the states for the content management cubit.
abstract class ContentState extends Equatable {
  const ContentState();
  @override
  List<Object> get props => [];
}

class ContentInitial extends ContentState {}

class ContentLoading extends ContentState {}

class ContentSuccess extends ContentState {
  final String message;
  const ContentSuccess(this.message);
}

class ContentError extends ContentState {
  final String message;
  const ContentError(this.message);
}
/// after lunch update

