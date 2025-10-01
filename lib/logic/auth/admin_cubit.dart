import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import 'admin_state.dart';

// AdminCubit manages admin actions for users and content
class AdminCubit extends Cubit<AdminState> {
  final AuthRepository authRepository; // Repository for auth operations
  AdminCubit({required this.authRepository}) : super(AdminInitial());

  // Fetch all users from Firestore
  Future<void> fetchAllUsers() async {
    emit(AdminLoading());
    try {
      final users = await FirebaseFirestore.instance.collection('users').get();
      final userModels = users.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      developer.log('Fetched ${userModels.length} users');
      emit(AllUsersLoaded(userModels));
    } catch (e) {
      developer.log('Error fetching all users: $e', error: e);
      String? errorCode = e.toString().contains('PERMISSION_DENIED') ? 'PERMISSION_DENIED' : null;
      emit(AdminError('Failed to fetch users: $e', errorCode: errorCode));
    }
  }

  // Fetch users with 'pending' status
  Future<void> fetchPendingUsers() async {
    emit(AdminLoading());
    try {
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('status', isEqualTo: 'pending')
          .get();
      final userModels = users.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      developer.log('Fetched ${userModels.length} pending users');
      emit(PendingUsersLoaded(userModels));
    } catch (e) {
      developer.log('Error fetching pending users: $e', error: e);
      String? errorCode = e.toString().contains('PERMISSION_DENIED') ? 'PERMISSION_DENIED' : null;
      emit(AdminError('Failed to fetch pending users: $e', errorCode: errorCode));
    }
  }

  // Fetch user details and device history
  Future<void> fetchUserDetails(String uid) async {
    emit(AdminLoading());
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        throw Exception('User document does not exist');
      }
      final user = UserModel.fromFirestore(userDoc);
      final devices = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('devices')
          .get();
      final deviceHistory = devices.docs.map((doc) => doc.data()).toList();
      developer.log('Fetched details for user: $uid, devices: ${deviceHistory.length}');
      emit(UserDetailsLoaded(user, deviceHistory));
    } catch (e) {
      developer.log('Error fetching user details: $e', error: e);
      String errorCode = e.toString().contains('PERMISSION_DENIED') ? 'PERMISSION_DENIED' : 'not-found';
      emit(AdminError('Failed to fetch user details: $e', errorCode: errorCode));
    }
  }

  // Approve a user
  Future<void> approveUser(String uid) async {
    emit(AdminLoading());
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'status': 'approved',
      });
      developer.log('User $uid approved');
      emit(AdminActionSuccess('User approved successfully', 'approve'));
    } catch (e) {
      developer.log('Error approving user: $e', error: e);
      String? errorCode = e.toString().contains('PERMISSION_DENIED') ? 'PERMISSION_DENIED' : null;
      emit(AdminError('Failed to approve user: $e', errorCode: errorCode));
    }
  }
 /* Future<void> approveUser(String uid) async {
    final callable = FirebaseFunctions.instance.httpsCallable('approveUser');
    await callable.call({'uid': uid});
  }*/

  // Reject a user and clear active devices
  Future<void> rejectUser(String uid) async {
    emit(AdminLoading());
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final activeToken = userDoc.data()?['activeToken'] as String?;
      if (activeToken != null) {
        final devices = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('devices')
            .where('token', isEqualTo: activeToken)
            .get();
        for (var device in devices.docs) {
          await device.reference.update({
            'logoutTime': FieldValue.serverTimestamp(),
          });
        }
      }
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'status': 'rejected',
        'activeToken': null,
      });
      developer.log('User $uid rejected');
      emit(AdminActionSuccess('User rejected successfully', 'reject'));
    } catch (e) {
      developer.log('Error rejecting user: $e', error: e);
      String? errorCode = e.toString().contains('PERMISSION_DENIED') ? 'PERMISSION_DENIED' : null;
      emit(AdminError('Failed to reject user: $e', errorCode: errorCode));
    }
  }

  // Revoke user approval
  Future<void> revokeApproval(String uid) async {
    emit(AdminLoading());
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final activeToken = userDoc.data()?['activeToken'] as String?;
      if (activeToken != null) {
        final devices = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('devices')
            .where('token', isEqualTo: activeToken)
            .get();
        for (var device in devices.docs) {
          await device.reference.update({
            'logoutTime': FieldValue.serverTimestamp(),
          });
        }
      }
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'status': 'pending',
        'activeToken': null,
      });
      developer.log('User $uid approval revoked');
      emit(AdminActionSuccess('User approval revoked successfully', 'revoke'));
    } catch (e) {
      developer.log('Error revoking approval: $e', error: e);
      String? errorCode = e.toString().contains('PERMISSION_DENIED') ? 'PERMISSION_DENIED' : null;
      emit(AdminError('Failed to revoke approval: $e', errorCode: errorCode));
    }
  }

  // Update user role
  Future<void> updateUserRole(String uid, String newRole) async {
    emit(AdminLoading());
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'role': newRole.toLowerCase(),
      });
      developer.log('User $uid role updated to $newRole');
      emit(AdminActionSuccess('User role updated to $newRole successfully', 'update_role'));
    } catch (e) {
      developer.log('Error updating user role: $e', error: e);
      String? errorCode = e.toString().contains('PERMISSION_DENIED') ? 'PERMISSION_DENIED' : null;
      emit(AdminError('Failed to update user role: $e', errorCode: errorCode));
    }
  }

  Future<int> getHistoricalDeviceCount(String uid) async {
    try {
      final devices = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('devices')
          .get();
      return devices.docs.length;
    } catch (e) {
      developer.log('Error fetching device count for $uid: $e', error: e);
      return 0;
    }
  }
  // Fetch all content (subjects) from Firestore
  Future<void> fetchContent() async {
    emit(AdminLoading());
    try {
      final subjects = await FirebaseFirestore.instance.collection('subjects').get();
      final contentModels = subjects.docs.map((doc) => ContentModel.fromFirestore(doc)).toList();
      developer.log('Fetched ${contentModels.length} subjects');
      emit(ContentLoaded(contentModels));
    } catch (e) {
      developer.log('Error fetching content: $e', error: e);
      String? errorCode = e.toString().contains('PERMISSION_DENIED') ? 'PERMISSION_DENIED' : null;
      emit(AdminError('Failed to fetch content: $e', errorCode: errorCode));
    }
  }

  // Add new content (subject)
  Future<void> addContent(String title, String description) async {
    emit(AdminLoading());
    try {
      final docRef = FirebaseFirestore.instance.collection('subjects').doc();
      final content = ContentModel(
        id: docRef.id,
        title: title,
        description: description,
        createdAt: Timestamp.now(),
      );
      await docRef.set(content.toFirestore());
      developer.log('Added content: ${content.id}');
      emit(AdminActionSuccess('Content added successfully', 'add_content'));
    } catch (e) {
      developer.log('Error adding content: $e', error: e);
      String? errorCode = e.toString().contains('PERMISSION_DENIED') ? 'PERMISSION_DENIED' : null;
      emit(AdminError('Failed to add content: $e', errorCode: errorCode));
    }
  }

  // Update existing content
  Future<void> updateContent(String id, String title, String description) async {
    emit(AdminLoading());
    try {
      await FirebaseFirestore.instance.collection('subjects').doc(id).update({
        'title': title.trim(),
        'description': description.trim(),
      });
      developer.log('Updated content: $id');
      emit(AdminActionSuccess('Content updated successfully', 'update_content'));
    } catch (e) {
      developer.log('Error updating content: $e', error: e);
      String? errorCode = e.toString().contains('PERMISSION_DENIED') ? 'PERMISSION_DENIED' : null;
      emit(AdminError('Failed to update content: $e', errorCode: errorCode));
    }
  }

  // Delete content
  Future<void> deleteContent(String id) async {
    emit(AdminLoading());
    try {
      await FirebaseFirestore.instance.collection('subjects').doc(id).delete();
      developer.log('Deleted content: $id');
      emit(AdminActionSuccess('Content deleted successfully', 'delete_content'));
    } catch (e) {
      developer.log('Error deleting content: $e', error: e);
      String? errorCode = e.toString().contains('PERMISSION_DENIED') ? 'PERMISSION_DENIED' : null;
      emit(AdminError('Failed to delete content: $e', errorCode: errorCode));
    }
  }
}