import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:developer' as developer;
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  AuthCubit({required this.authRepository}) : super(AuthInitial());

  Future<void> init() async {
    developer.log('Initializing AuthCubit');
    emit(AuthLoading());
    try {
      final user = authRepository.currentUser;
      if (user != null) {
        final userModel = await authRepository.getUser(user.uid);
        emit(Authenticated(firebaseUser: user, userModel: userModel));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      developer.log('Error initializing AuthCubit: $e', error: e);
      emit(AuthError(message: 'Failed to initialize: $e'));
    }
  }
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String college, // ADDED
    required String branch,  // ADDED
  }) async
  {
    // Tell the UI that the registration process has started
    emit(AuthLoading());
    try {
      // Call the updated repository method, passing all the required fields
      final userModel = await authRepository.register(
        email: email.trim(),
        password: password,
        name: name.trim(),
        college: college.trim(), // ADDED
        branch: branch.trim(),   // ADDED
      );

      // On success, log the event and emit the Authenticated state
      developer.log('User registered: ${userModel.uid}');
      emit(Authenticated(
          firebaseUser: FirebaseAuth.instance.currentUser!,
          userModel: userModel));
    } catch (e) {
      // On failure, log the error and create a user-friendly message
      developer.log('Registration error: $e', error: e);
      String message = 'Failed to register: $e';

      // Provide specific feedback for common Firebase errors
      if (e.toString().contains('cloud_firestore/permission-denied')) {
        message = 'Permission denied. Please check Firestore rules.';
      } else if (e.toString().contains('email-already-in-use')) {
        message = 'This email is already registered.';
      } else if (e.toString().contains('invalid-email')) {
        message = 'The email address is not valid.';
      } else if (e.toString().contains('weak-password')) {
        message = 'Password is too weak. Please use at least 6 characters.';
      }

      // Tell the UI that an error occurred
      emit(AuthError(message: message));
    }
  }
  Future<void> login({
    required String email,
    required String password,
    required String deviceId,
    required String deviceName,
    required String deviceType,
  }) async
  {
    emit(AuthLoading());
    try {
      developer.log('Login attempt for email: $email');
      await authRepository.loginUser(
        email: email,
        password: password,
        deviceId: deviceId,
        deviceName: deviceName,
        deviceType: deviceType,
      );
      final user = authRepository.currentUser!;
      final userModel = await authRepository.getUser(user.uid);
      developer.log('Login successful, emitting Authenticated for user: ${userModel.uid}');
      emit(Authenticated(firebaseUser: user, userModel: userModel));
    } catch (e) {
      developer.log('Error logging in: $e', error: e);
      String message;
      if (e.toString().contains('Account not approved')) {
        message = 'Account not approved. Please wait for admin approval.';
      } else if (e.toString().contains('invalid-credential')) {
        message = 'Invalid email or password.';
      } else {
        message = 'Failed to login: $e';
      }
      emit(AuthError(message: message));
    }
  }

// lib/logic/auth/auth_cubit.dart


// lib/logic/auth/auth_cubit.dart

// ... inside your AuthCubit class ...
  Future<void> updateProfile({
    required String name,
    // required String email, // REMOVED
    required String college,
    required String branch,
  }) async {
    if (state is! Authenticated) return;

    final originalState = state as Authenticated;
    final user = originalState.userModel;

    emit(AuthLoading());
    try {
      await authRepository.updateUserProfile(
        uid: user.uid,
        name: name,
        // email: email, // REMOVED
        college: college,
        branch: branch,
      );

      final updatedUserModel = user.copyWith(
        name: name,
        // email: email, // REMOVED
        college: college,
        branch: branch,
      );

      emit(Authenticated(firebaseUser: originalState.firebaseUser, userModel: updatedUserModel));

    } catch (e) {
      emit(AuthError(message: 'Failed to update profile: $e'));
      emit(originalState);
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      developer.log('Sign out successful, emitting Unauthenticated');
      emit(Unauthenticated());
    } catch (e) {
      developer.log('Sign out failed: $e', error: e);
      emit(AuthError(message: 'Failed to sign out: $e'));
    }
  }
}

/*// lib/logic/auth/auth_bloc.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    // Register the event handlers for each event
    on<AppStarted>(_onAppStarted);
    on<RegisterUser>(_onRegisterUser);
    on<LoginUser>(_onLoginUser);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<LogoutUser>(_onLogoutUser);
  }

  // Handles the AppStarted event (replaces the old init() method)
  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    developer.log('Initializing AuthBloc');
    emit(AuthLoading());
    try {
      final user = authRepository.currentUser;
      if (user != null) {
        final userModel = await authRepository.getUser(user.uid);
        emit(Authenticated(firebaseUser: user, userModel: userModel));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      developer.log('Error initializing AuthBloc: $e', error: e);
      emit(AuthError(message: 'Failed to initialize: $e'));
    }
  }

  // Handles the RegisterUser event
  Future<void> _onRegisterUser(RegisterUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userModel = await authRepository.register(
        email: event.email.trim(),
        password: event.password,
        name: event.name.trim(),
        college: event.college.trim(),
        branch: event.branch.trim(),
      );
      developer.log('User registered: ${userModel.uid}');
      // Emit the new specific state for pending approval
      emit(RegistrationSuccessPendingApproval());
    } catch (e) {
      developer.log('Registration error: $e', error: e);
      String message = 'Failed to register: $e';
      if (e.toString().contains('email-already-in-use')) {
        message = 'This email is already registered.';
      } else if (e.toString().contains('invalid-email')) {
        message = 'The email address is not valid.';
      } else if (e.toString().contains('weak-password')) {
        message = 'Password is too weak. Please use at least 6 characters.';
      }
      emit(AuthError(message: message));
    }
  }

  // Handles the LoginUser event
  Future<void> _onLoginUser(LoginUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      developer.log('Login attempt for email: ${event.email}');
      await authRepository.loginUser(
        email: event.email,
        password: event.password,
        deviceId: event.deviceId,
        deviceName: event.deviceName,
        deviceType: event.deviceType,
      );
      final user = authRepository.currentUser!;
      final userModel = await authRepository.getUser(user.uid);
      developer.log('Login successful, emitting Authenticated for user: ${userModel.uid}');
      emit(Authenticated(firebaseUser: user, userModel: userModel));
    } catch (e) {
      developer.log('Error logging in: $e', error: e);
      String message;
      if (e.toString().contains('Account not approved')) {
        message = 'Account not approved. Please wait for admin approval.';
      } else if (e.toString().contains('invalid-credential')) {
        message = 'Invalid email or password.';
      } else {
        message = 'Failed to login: $e';
      }
      emit(AuthError(message: message));
    }
  }

  // Handles the UpdateUserProfile event
  Future<void> _onUpdateUserProfile(UpdateUserProfile event, Emitter<AuthState> emit) async {
    if (state is! Authenticated) return;
    final originalState = state as Authenticated;

    emit(AuthLoading());
    try {
      await authRepository.updateUserProfile(
        uid: originalState.userModel.uid,
        name: event.name,
        college: event.college,
        branch: event.branch,
      );
      final updatedUserModel = originalState.userModel.copyWith(
        name: event.name,
        college: event.college,
        branch: event.branch,
      );
      emit(Authenticated(firebaseUser: originalState.firebaseUser, userModel: updatedUserModel));
    } catch (e) {
      emit(AuthError(message: 'Failed to update profile: $e'));
      emit(originalState);
    }
  }

  // Handles the LogoutUser event
  Future<void> _onLogoutUser(LogoutUser event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      developer.log('Sign out successful, emitting Unauthenticated');
      emit(const Unauthenticated());
    } catch (e) {
      developer.log('Sign out failed: $e', error: e);
      emit(AuthError(message: 'Failed to sign out: $e'));
    }
  }
}*/