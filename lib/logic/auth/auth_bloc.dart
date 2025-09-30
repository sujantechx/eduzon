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
  // lib/logic/auth/auth_cubit.dart

// ... inside your AuthCubit class ...

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String address,
    required String courseId,
    required String phone, // The UI sends a String
    required String paymentId,
  }) async {
    emit(AuthLoading());
    try {
      // Convert the phone string to a number. Handle errors if it's not a valid number.
      final phoneNum = num.tryParse(phone);
      if (phoneNum == null) {
        throw Exception('Phone number must be a valid number.');
      }

      // Call the repository with all the correct, cleaned data
      final userModel = await authRepository.register(
        email: email.trim(),
        password: password,
        name: name.trim(),
        address: address.trim(),
        courseId: courseId.trim(),
        paymentId: paymentId.trim(),
        phone: phone, // Pass the converted number
      );

      developer.log('User registered, pending approval: ${userModel.uid}');
      // ✅ On success, emit the specific state for pending approval.
      emit(RegistrationSuccessPendingApproval());

    } catch (e) {
      // ... (Your existing error handling is good)
      developer.log('Registration error: $e', error: e);
      String message = e.toString().replaceFirst('Exception: ', '');
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
    required String branch, required String address, required String courseId, required String phone,
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
        branch: branch, address: '', courseId: '',
      );

      final updatedUserModel = user.copyWith(
        name: name,
        // email: email, // REMOVED
        address: address,

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
