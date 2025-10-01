import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;
import '../../data/models/user_model.dart';
import 'package:uuid/uuid.dart';

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final DeviceInfoPlugin _deviceInfo;
  final Uuid _uuid;

  AuthRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    DeviceInfoPlugin? deviceInfo,
    Uuid? uuid,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
        _uuid = uuid ?? const Uuid();

  User? get currentUser => _auth.currentUser;

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String address,
    required String courseId,
    required String phone,
    required String paymentId,
  }) async {
    try {
      // 1. Create the user in Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user!;

      // 2. Create a new UserModel instance with all the required data
      final newUser = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        address: address,
        courseId: courseId,
        phone: phone,
        paymentId: paymentId,
        role: 'student',   // Default role
        status: 'pending',
        courseTitle: '', // Default status
      );

      // 3. Save the complete user model to Firestore
      await _firestore.collection('users').doc(user.uid).set(newUser.toFirestore());

      // 4. Return the newly created user model
      return newUser;
    } catch (e) {
      developer.log('Registration error: $e', error: e);
      throw Exception('Registration failed: $e');
    }
  }
  Future<UserModel> getUser(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        throw Exception('User document does not exist');
      }
      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      developer.log('Error fetching user: $e', error: e);
      throw Exception('Failed to fetch user: $e');
    }
  }


  Future<void> loginUser({
    required String email,
    required String password,
    required String deviceId,
    required String deviceName,
    required String deviceType,
  }) async
  {
    try {
      developer.log('Logging in user: $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user!;
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('User document does not exist');
      }
      final userData = userDoc.data()!;
      if (userData['status'] != 'approved' && userData['status'] != 'approve') {
        await _auth.signOut();
        throw Exception('Account not approved');
      }
      if (userData['activeToken'] != null) {
        await _auth.signOut();
        throw Exception('User already logged in on another device');
      }
      final token = _uuid.v4();
      await _firestore.collection('users').doc(user.uid).update({
        'activeToken': token,
        'lastLogin': FieldValue.serverTimestamp(),
      });
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('devices')
          .doc(deviceId)
          .set({
        'name': deviceName,
        'type': deviceType,
        'token': token,
        'loginTime': FieldValue.serverTimestamp(),
        'logoutTime': null,
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log('Login error: $e', error: e);
      throw Exception('Failed to login: $e');
    }
  }


  Future<void> signOut() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        final activeToken = userDoc.data()?['activeToken'];
        if (activeToken != null) {
          final devices = await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('devices')
              .where('token', isEqualTo: activeToken)
              .get();
          for (var device in devices.docs) {
            await device.reference.update({
              'logoutTime': FieldValue.serverTimestamp(),
            });
          }
          await _firestore.collection('users').doc(user.uid).update({
            'activeToken': null,
          });
        }
        await _auth.signOut();
      }
    } catch (e) {
      developer.log('Sign out error: $e', error: e);
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> clearActiveDevice(String uid, String deviceId) async {
    try {
      final deviceDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('devices')
          .doc(deviceId)
          .get();
      if (deviceDoc.exists) {
        await deviceDoc.reference.update({
          'logoutTime': FieldValue.serverTimestamp(),
        });
      }
      await _firestore.collection('users').doc(uid).update({
        'activeToken': null,
      });
    } catch (e) {
      developer.log('Error clearing active device: $e', error: e);
      throw Exception('Failed to clear active device: $e');
    }
  }



  Future<List<UserModel>> getPendingUsers() async {
    try {
      developer.log('Fetching pending users');
      final snapshot = await _firestore
          .collection('users')
          .where('status', isEqualTo: 'pending')
          .get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      developer.log('Error fetching pending users: $e', error: e);
      throw Exception('Failed to fetch pending users: $e');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      developer.log('Fetching all users');
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      developer.log('Error fetching all users: $e', error: e);
      throw Exception('Failed to fetch all users: $e');
    }
  }

  Future<int> getHistoricalDeviceCount(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).collection('devices').get();
    return snapshot.docs.length;
  }

  Stream<List<Map<String, dynamic>>> getDeviceHistory(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('devices')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

// lib/data/repositories/auth_repository.dart

// ... inside your AuthRepository class ...
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String address,
    required String courseTitle,
    required String phone, required String courseName, required String courseId,
  }) async {
    try {
      final updateData = const UserModel(uid: '', name: '', email: '', address: '', courseTitle: '',phone:'', paymentId: '', courseId: '')
          .toFirestoreUpdate(
        name: name,
        address: address,
        courseTitle: courseTitle,
        phone: phone,
      );
      await _firestore.collection('users').doc(uid).update(updateData);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<void> updateUserStatus(String uid, String status) async {
    try {
      developer.log('Updating user status: $uid to $status');
      if (!['approved', 'rejected', 'pending'].contains(status)) {
        throw Exception('Invalid status: $status');
      }
      await _firestore.collection('users').doc(uid).update({'status': status});
    } catch (e) {
      developer.log('Error updating user status: $e', error: e);
      throw Exception('Failed to update user status: $e');
    }
  }


}