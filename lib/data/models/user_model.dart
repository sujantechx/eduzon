// lib/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String address;
  final String courseId;
  final String role;
  final String status;
  final String? activeToken;
  final Timestamp? createdAt;
  final Timestamp? lastLogin;
  final String phone;
  final String paymentId;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.address,
    required this.courseId,
    required this.phone,
    required this.paymentId,
    this.role = 'student',
    this.status = 'pending',
    this.activeToken,
    this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      name: (data['name'] as String?)?.trim() ?? 'Unknown',
      email: (data['email'] as String?)?.trim().toLowerCase() ?? '',
      address: (data['address'] as String?)?.trim() ?? 'Unknown',
      courseId: (data['courseId'] as String?)?.trim() ?? 'Unknown',
      role: (data['role'] as String?)?.toLowerCase() ?? 'student',
      status: (data['status'] as String?)?.toLowerCase() ?? 'pending',
      activeToken: data['activeToken'] as String?,
      createdAt: data['createdAt'] as Timestamp?,
      lastLogin: data['lastLogin'] as Timestamp?,
      phone: data['phone'] as String? ?? '',
      paymentId: data['paymentId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'address': address.trim(),
      'courseId': courseId.trim(),
      'role': role.toLowerCase(),
      'status': status.toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
      'activeToken': activeToken,
      'lastLogin': lastLogin,
      'phone': phone,
      'paymentId': paymentId,
    };
  }

  Map<String, dynamic> toFirestoreUpdate({
    String? name,
    String? email,
    String? address, // CORRECTED
    String? courseId,
    String? role,
    String? status,
    String? activeToken,
    String? phone,       // CORRECTED
    String? paymentId,
  }) {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name.trim();
    if (email != null) {
      if (!_isValidEmail(email)) throw ArgumentError('Invalid email format: $email');
      updates['email'] = email.trim().toLowerCase();
    }
    if (address != null) updates['address'] = address.trim(); // CORRECTED
    if (courseId != null) updates['courseId'] = courseId.trim(); // CORRECTED
    if (role != null) updates['role'] = role.toLowerCase();
    if (status != null) updates['status'] = status.toLowerCase();
    if (activeToken != null) updates['activeToken'] = activeToken;
    if (phone != null) updates['phone'] = phone;
    if (paymentId != null) updates['paymentId'] = paymentId;
    return updates;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? address, // CORRECTED
    String? courseId,
    String? role,
    String? status,
    String? activeToken,
    Timestamp? createdAt,
    Timestamp? lastLogin,
    num? phone,
    String? paymentId,
  }) {
    return UserModel(
      uid: uid,
      name: name?.trim() ?? this.name,
      email: email?.trim().toLowerCase() ?? this.email,
      address: address?.trim() ?? this.address, // CORRECTED
      courseId: courseId?.trim() ?? this.courseId,
      role: role?.toLowerCase() ?? this.role,
      status: status?.toLowerCase() ?? this.status,
      activeToken: activeToken ?? this.activeToken,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      phone: phone?.toString() ?? this.phone,
      paymentId: paymentId ?? this.paymentId,
    );
  }

  @override
  List<Object?> get props => [
    uid, name, email, address, courseId, role, status,
    activeToken, createdAt, lastLogin, phone, paymentId,
  ];
}