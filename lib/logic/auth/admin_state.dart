import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

// ContentModel represents a subject or course in Firestore 'subjects' collection
class ContentModel extends Equatable {
  final String id; // Unique subject ID
  final String title; // Subject title
  final String description; // Subject description
  final Timestamp createdAt; // Creation timestamp

  const ContentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory ContentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ContentModel(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled',
      description: data['description'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) throw ArgumentError('Title cannot be empty');
    return {
      'title': trimmedTitle,
      'description': description.trim(),
      'createdAt': createdAt,
    };
  }

  @override
  List<Object> get props => [id, title, description, createdAt];
}

// Base AdminState class for managing admin-related states
abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

// Initial state when AdminCubit is created
class AdminInitial extends AdminState {}

// Loading state during async operations
class AdminLoading extends AdminState {}

// State when pending users are loaded
class PendingUsersLoaded extends AdminState {
  final List<UserModel> users; // List of users with 'pending' status
  const PendingUsersLoaded(this.users);
  @override
  List<Object> get props => [users];
}

// State when all users are loaded
class AllUsersLoaded extends AdminState {
  final List<UserModel> users; // List of all users
  const AllUsersLoaded(this.users);
  @override
  List<Object> get props => [users];
}

// State when a user's details and device history are loaded
class UserDetailsLoaded extends AdminState {
  final UserModel user; // Single user
  final List<Map<String, dynamic>> deviceHistory; // Device history
  const UserDetailsLoaded(this.user, this.deviceHistory);
  @override
  List<Object> get props => [user, deviceHistory];
}

// State when content (subjects) is loaded
class ContentLoaded extends AdminState {
  final List<ContentModel> content; // List of subjects
  const ContentLoaded(this.content);
  @override
  List<Object> get props => [content];
}

// State for successful admin actions
class AdminActionSuccess extends AdminState {
  final String message; // Success message
  final String action; // Action type (e.g., 'approve', 'reject', 'add_content')
  const AdminActionSuccess(this.message, this.action);
  @override
  List<Object> get props => [message, action];
}

// State for admin action errors
class AdminError extends AdminState {
  final String message; // Error message
  final String? errorCode; // Optional error code (e.g., 'PERMISSION_DENIED')
  const AdminError(this.message, {this.errorCode});
  @override
  List<Object?> get props => [message, errorCode];
}