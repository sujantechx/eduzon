// lib/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// UserModel represents a user in the Firestore 'users' collection
class UserModel extends Equatable {
  final String uid; // Unique user ID from Firebase Auth
  final String name; // User's name
  final String email; // User's email
  final String college; // User's college
  final String branch; // User's branch
  final String role; // User role ('admin' or 'student')
  final String status; // User status ('pending', 'approved', 'rejected')
  final String? activeToken; // Active device token, nullable
  final Timestamp? createdAt; // Account creation timestamp, nullable
  final Timestamp? lastLogin; // Last login timestamp, nullable

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.college,
    required this.branch,
    this.role = 'student',
    this.status = 'pending',
    this.activeToken,
    this.createdAt,
    this.lastLogin,
  });

  // Factory to create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      name: (data['name'] as String?)?.trim() ?? 'Unknown',
      email: (data['email'] as String?)?.trim().toLowerCase() ?? '',
      college: (data['college'] as String?)?.trim() ?? 'Unknown',
      branch: (data['branch'] as String?)?.trim() ?? 'Unknown',
      role: (data['role'] as String?)?.toLowerCase() ?? 'student',
      status: (data['status'] as String?)?.toLowerCase() ?? 'pending',
      activeToken: data['activeToken'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
      lastLogin: data['lastLogin'] as Timestamp?,
    );
  }

  // Convert UserModel to Firestore-compatible map for creating a new document
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'college': college.trim(),
      'branch': branch.trim(),
      'role': role.toLowerCase(),
      'status': status.toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(), // Always set on creation
      'activeToken': activeToken,
      'lastLogin': lastLogin,
    };
  }

  // Creates a map for partial updates to a Firestore document
  Map<String, dynamic> toFirestoreUpdate({
    String? name,
    String? email,
    String? college,
    String? branch,
    String? role,
    String? status,
    String? activeToken,
  }) {
    final updates = <String, dynamic>{};
    if (name != null) {
      updates['name'] = name.trim();
    }
    if (email != null) {
      if (!_isValidEmail(email)) throw ArgumentError('Invalid email format: $email');
      updates['email'] = email.trim().toLowerCase();
    }
    // ** ADDED THIS LOGIC **
    if (college != null) {
      updates['college'] = college.trim();
    }
    if (branch != null) {
      updates['branch'] = branch.trim();
    }
    // ** END OF ADDED LOGIC **
    if (role != null) {
      if (!['student', 'admin'].contains(role.toLowerCase())) {
        throw ArgumentError('Invalid role: $role');
      }
      updates['role'] = role.toLowerCase();
    }
    if (status != null) {
      if (!['pending', 'approved', 'rejected'].contains(status.toLowerCase())) {
        throw ArgumentError('Invalid status: $status');
      }
      updates['status'] = status.toLowerCase();
    }
    if (activeToken != null) {
      updates['activeToken'] = activeToken;
    }
    return updates;
  }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Create a copy of UserModel with optional updates
  UserModel copyWith({
    String? name,
    String? email,
    String? college,
    String? branch,
    String? role,
    String? status,
    String? activeToken,
    Timestamp? createdAt,
    Timestamp? lastLogin,
  }) {
    return UserModel(
      uid: uid,
      name: name?.trim() ?? this.name,
      email: email?.trim().toLowerCase() ?? this.email,
      college: college?.trim() ?? this.college,
      branch: branch?.trim() ?? this.branch,
      role: role?.toLowerCase() ?? this.role,
      status: status?.toLowerCase() ?? this.status,
      activeToken: activeToken ?? this.activeToken,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  // Equatable props for state comparison
  @override
  List<Object?> get props => [
    uid,
    name,
    email,
    college,
    branch,
    role,
    status,
    activeToken,
    createdAt,
    lastLogin,
  ];
}