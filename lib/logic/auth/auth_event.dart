/*
// lib/logic/auth/auth_event.dart

import 'package:equatable/equatable.dart';

// Abstract class for all authentication events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

// Event triggered when the app starts to check the current auth state.
class AppStarted extends AuthEvent {}

// Event triggered when a user attempts to register.
class RegisterUser extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String college;
  final String branch;

  const RegisterUser({
    required this.email,
    required this.password,
    required this.name,
    required this.college,
    required this.branch,
  });

  @override
  List<Object> get props => [email, password, name, college, branch];
}

// Event triggered when a user attempts to log in.
class LoginUser extends AuthEvent {
  final String email;
  final String password;
  final String deviceId;
  final String deviceName;
  final String deviceType;

  const LoginUser({
    required this.email,
    required this.password,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
  });
  @override
  List<Object> get props => [email, password, deviceId, deviceName, deviceType];
}

// Event triggered when a user updates their profile.
class UpdateUserProfile extends AuthEvent {
  final String name;
  final String college;
  final String branch;

  const UpdateUserProfile({
    required this.name,
    required this.college,
    required this.branch,
  });
  @override
  List<Object> get props => [name, college, branch];
}

// Event triggered when a user logs out.
class LogoutUser extends AuthEvent {}*/
