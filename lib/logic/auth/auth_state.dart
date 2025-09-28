import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

//  NEW STATE: Specific state for when registration is successful but needs approval.
class RegistrationSuccessPendingApproval extends AuthState {}

class Authenticated extends AuthState {
  final User? firebaseUser;
  final UserModel userModel;
  const Authenticated({this.firebaseUser, required this.userModel});
  @override
  List<Object?> get props => [firebaseUser, userModel];
}

class Unauthenticated extends AuthState {
  final bool pendingApproval;

  const Unauthenticated({this.pendingApproval = false});

  @override
  List<Object?> get props => [pendingApproval];
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}