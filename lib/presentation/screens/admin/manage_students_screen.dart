import 'package:eduzon/data/models/user_model.dart';
import 'package:eduzon/data/repositories/auth_repository.dart';
import 'package:eduzon/logic/auth/admin_cubit.dart';
import 'package:eduzon/logic/auth/admin_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  String _filterStatus = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    developer.log('Initializing ManageStudentsScreen');
    context.read<AdminCubit>().fetchAllUsers();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ CORRECTED: Ensure status names match the ones in your repository.
  List<UserModel> _filterUsers(List<UserModel> users) {
    return users.where((user) {
      final matchesStatus = _filterStatus == 'All' ||
          user.status == _filterStatus.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery) ||
          user.email.toLowerCase().contains(_searchQuery) ||
          user.phone.toLowerCase().contains(_searchQuery); // Search by phone
      return matchesStatus && matchesSearch;
    }).toList();
  }

  void _confirmAction(BuildContext context, String action, String uid, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm $action'),
        content: Text('Are you sure you want to $action this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }

  void _showRoleUpdateDialog(BuildContext context, String uid, String currentRole) {
    final roleController = TextEditingController(text: currentRole);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update User Role'),
        content: TextField(
          controller: roleController,
          decoration: const InputDecoration(
            labelText: 'Role',
            hintText: 'Enter role (e.g., admin, student)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newRole = roleController.text.trim().toLowerCase();
              if (['admin', 'student'].contains(newRole)) {
                context.read<AdminCubit>().updateUserRole(uid, newRole);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid role. Use "admin" or "student".')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          DropdownButton<String>(
            value: _filterStatus,
            items: ['All', 'Pending', 'Approved', 'Rejected']
                .map((status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _filterStatus = value!;
                developer.log('Filter status changed to: $_filterStatus');
                if (_filterStatus == 'Pending') {
                  context.read<AdminCubit>().fetchPendingUsers();
                } else {
                  context.read<AdminCubit>().fetchAllUsers();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name, email or phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<AdminCubit, AdminState>(
              listener: (context, state) {
                developer.log('AdminCubit state: $state');
                if (state is AdminActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                  // Refresh the user list based on the current filter
                  if (_filterStatus == 'Pending') {
                    context.read<AdminCubit>().fetchPendingUsers();
                  } else {
                    context.read<AdminCubit>().fetchAllUsers();
                  }
                } else if (state is AdminError) {
                  String message = state.message;
                  if (state.errorCode == 'PERMISSION_DENIED') {
                    message = 'Permission denied. Ensure you are logged in as an admin.';
                  } else if (state.errorCode == 'not-found') {
                    message = 'User not found in Firestore.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<UserModel> users = [];
                if (_filterStatus == 'Pending' && state is PendingUsersLoaded) {
                  users = state.users;
                } else if (state is AllUsersLoaded) {
                  users = state.users;
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No users found'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _filterStatus == 'Pending'
                              ? context.read<AdminCubit>().fetchPendingUsers()
                              : context.read<AdminCubit>().fetchAllUsers(),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }
                final filteredUsers = _filterUsers(users);
                if (filteredUsers.isEmpty) {
                  return const Center(child: Text('No matching users found'));
                }
                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return ExpansionTile(
                      title: Text(user.name),
                      subtitle: Text('Email: ${user.email} | Status: ${user.status}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Role: ${user.role}'),
                              Text('Last Login: ${user.lastLogin?.toDate().toString() ?? 'Never'}'),
                              // ✅ Added phone, paymentId
                              Text('Phone: ${user.phone}'),
                              Text('Payment ID: ${user.paymentId}'),
                              // ✅ Added FutureBuilder for course name
                              FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('courses').doc(user.courseId).get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Text('Course Name: Loading...');
                                  }
                                  if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                                    return const Text('Course Name: Not Found');
                                  }
                                  final courseData = snapshot.data!.data() as Map<String, dynamic>;
                                  return Text('Course Name: ${courseData['title']}');
                                },
                              ),
                              const SizedBox(height: 8),
                              Text('Active Token: ${user.activeToken ?? 'None'}'),
                              FutureBuilder<int>(
                                future: context.read<AuthRepository>().getHistoricalDeviceCount(user.uid),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text('Error loading device count');
                                  }
                                  if (snapshot.hasData) {
                                    return Text('Devices Used: ${snapshot.data}');
                                  }
                                  return const Text('Loading device count...');
                                },
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<AdminCubit>().fetchUserDetails(user.uid);
                                  showDialog(
                                    context: context,
                                    builder: (context) => BlocBuilder<AdminCubit, AdminState>(
                                      builder: (context, state) {
                                        if (state is AdminLoading) {
                                          return const AlertDialog(
                                            title: Text('Loading...'),
                                            content: Center(child: CircularProgressIndicator()),
                                          );
                                        }
                                        if (state is UserDetailsLoaded && state.user.uid == user.uid) {
                                          return AlertDialog(
                                            title: Text('Device History for ${user.name}'),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: state.deviceHistory.isEmpty
                                                    ? [const Text('No device history available')]
                                                    : state.deviceHistory.map((device) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: 8.0),
                                                    child: Card(
                                                      elevation: 2,
                                                      child: ListTile(
                                                        title: Text(device['name'] ?? 'Unknown Device'),
                                                        subtitle: Text(
                                                          'Type: ${device['type'] ?? 'N/A'}\n'
                                                              'Token: ${device['token'] ?? 'N/A'}\n'
                                                              'Login: ${device['loginTime']?.toDate().toString() ?? 'N/A'}\n'
                                                              'Logout: ${device['logoutTime']?.toDate().toString() ?? 'Active'}',
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          );
                                        }
                                        return AlertDialog(
                                          title: const Text('Error'),
                                          content: Text(state is AdminError
                                              ? state.message
                                              : 'Failed to load device history'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: const Text('View Device History'),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (user.status == 'pending') ...[
                                    ElevatedButton(
                                      onPressed: () => _confirmAction(
                                        context,
                                        'approved',
                                        user.uid,
                                            () => context.read<AdminCubit>().approveUser(user.uid),
                                      ),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      child: const Text('Approve'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _confirmAction(
                                        context,
                                        'Reject',
                                        user.uid,
                                            () => context.read<AdminCubit>().rejectUser(user.uid),
                                      ),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                  if (user.status == 'approved') ...[
                                    ElevatedButton(
                                      onPressed: () => _confirmAction(
                                        context,
                                        'Revoke Approval',
                                        user.uid,
                                            () => context.read<AdminCubit>().revokeApproval(user.uid),
                                      ),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                      child: const Text('Revoke Approval'),
                                    ),
                                  ],
                                  ElevatedButton(
                                    onPressed: () => _showRoleUpdateDialog(context, user.uid, user.role),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                    child: const Text('Update Role'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _filterStatus == 'Pending'
            ? context.read<AdminCubit>().fetchPendingUsers()
            : context.read<AdminCubit>().fetchAllUsers(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../logic/auth/admin_cubit.dart';
import '../../../logic/auth/admin_state.dart';

// Screen for admins to manage users (approve, reject, revoke, update roles)
class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  // Current filter status for user list (All, Pending, Approved, Rejected)
  String _filterStatus = 'All';
  // Controller for search input
  final _searchController = TextEditingController();
  // Current search query
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Log initialization for debugging
    developer.log('Initializing ManageStudentsScreen');
    // Fetch all users on screen load
    context.read<AdminCubit>().fetchAllUsers();
    // Update search query when user types
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    // Clean up search controller
    _searchController.dispose();
    super.dispose();
  }

  // Filter users based on status and search query
  List<UserModel> _filterUsers(List<UserModel> users) {
    return users.where((user) {
      // Normalize 'approve' to 'approved' for display consistency
      final normalizedStatus = user.status == 'approve' ? 'approved' : user.status;
      // Check if user matches filter status
      final matchesStatus = _filterStatus == 'All' ||
          (_filterStatus == 'Approved' && (normalizedStatus == 'approved' || normalizedStatus == 'approve')) ||
          normalizedStatus == _filterStatus.toLowerCase();
      // Check if user matches search query
      final matchesSearch = _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery) ||
          user.email.toLowerCase().contains(_searchQuery);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  // Show confirmation dialog for critical actions (approve, reject, revoke)
  void _confirmAction(BuildContext context, String action, String uid, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm $action'),
        content: Text('Are you sure you want to $action this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }

  // Show dialog to update user role
  void _showRoleUpdateDialog(BuildContext context, String uid, String currentRole) {
    final roleController = TextEditingController(text: currentRole);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update User Role'),
        content: TextField(
          controller: roleController,
          decoration: const InputDecoration(
            labelText: 'Role',
            hintText: 'Enter role (e.g., admin, student)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newRole = roleController.text.trim().toLowerCase();
              if (['admin', 'student'].contains(newRole)) {
                context.read<AdminCubit>().updateUserRole(uid, newRole);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid role. Use "admin" or "student".')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          // Dropdown to filter users by status
          DropdownButton<String>(
            value: _filterStatus,
            items: ['All', 'Pending', 'Approved', 'Rejected']
                .map((status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _filterStatus = value!;
                developer.log('Filter status changed to: $_filterStatus');
                // Fetch appropriate users based on filter
                if (_filterStatus == 'Pending') {
                  context.read<AdminCubit>().fetchPendingUsers();
                } else {
                  context.read<AdminCubit>().fetchAllUsers();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar for filtering users by name or email
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name or email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          // User list with Bloc state management
          Expanded(
            child: BlocConsumer<AdminCubit, AdminState>(
              listener: (context, state) {
                // Log state changes for debugging
                developer.log('AdminCubit state: $state');
                // Show success messages and refresh user list
                if (state is AdminActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                  if (_filterStatus == 'Pending') {
                    context.read<AdminCubit>().fetchPendingUsers();
                  } else {
                    context.read<AdminCubit>().fetchAllUsers();
                  }
                } else if (state is AdminError) {
                  // Handle errors with user-friendly messages
                  String message = state.message;
                  if (state.errorCode == 'PERMISSION_DENIED') {
                    message = 'Permission denied. Ensure you are logged in as an admin.';
                  } else if (state.errorCode == 'not-found') {
                    message = 'User not found in Firestore.';
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                }
              },
              builder: (context, state) {
                // Show loading indicator during async operations
                if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<UserModel> users = [];
                // Handle different states for user list
                if (_filterStatus == 'Pending' && state is PendingUsersLoaded) {
                  users = state.users;
                } else if (state is AllUsersLoaded) {
                  users = state.users;
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No users found'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _filterStatus == 'Pending'
                              ? context.read<AdminCubit>().fetchPendingUsers()
                              : context.read<AdminCubit>().fetchAllUsers(),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }
                // Filter users based on status and search
                final filteredUsers = _filterUsers(users);
                if (filteredUsers.isEmpty) {
                  return const Center(child: Text('No matching users found'));
                }
                // Display user list
                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return ExpansionTile(
                      title: Text(user.name),
                      subtitle: Text('Email: ${user.email} | Status: ${user.status == 'approve' ? 'Approved' : user.status}'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Role: ${user.role}'),
                              Text('Last Login: ${user.lastLogin?.toDate().toString() ?? 'Never'}'),
                              Text('Active Token: ${user.activeToken ?? 'None'}'),
                              // Fetch and display historical device count
                              FutureBuilder<int>(
                                future: context.read<AuthRepository>().getHistoricalDeviceCount(user.uid),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text('Error loading device count');
                                  }
                                  if (snapshot.hasData) {
                                    return Text('Devices Used: ${snapshot.data}');
                                  }
                                  return const Text('Loading device count...');
                                },
                              ),
                              const SizedBox(height: 8),
                              // Button to view device history
                              ElevatedButton(
                                onPressed: () {
                                  context.read<AdminCubit>().fetchUserDetails(user.uid);
                                  showDialog(
                                    context: context,
                                    builder: (context) => BlocBuilder<AdminCubit, AdminState>(
                                      builder: (context, state) {
                                        if (state is AdminLoading) {
                                          return const AlertDialog(
                                            title: Text('Loading...'),
                                            content: Center(child: CircularProgressIndicator()),
                                          );
                                        }
                                        if (state is UserDetailsLoaded && state.user.uid == user.uid) {
                                          return AlertDialog(
                                            title: Text('Device History for ${user.name}'),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: state.deviceHistory.isEmpty
                                                    ? [const Text('No device history available')]
                                                    : state.deviceHistory.map((device) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: 8.0),
                                                    child: Card(
                                                      elevation: 2,
                                                      child: ListTile(
                                                        title: Text(device['name'] ?? 'Unknown Device'),
                                                        subtitle: Text(
                                                          'Type: ${device['type'] ?? 'N/A'}\n'
                                                              'Token: ${device['token'] ?? 'N/A'}\n'
                                                              'Login: ${device['loginTime']?.toDate().toString() ?? 'N/A'}\n'
                                                              'Logout: ${device['logoutTime']?.toDate().toString() ?? 'Active'}',
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          );
                                        }
                                        return AlertDialog(
                                          title: const Text('Error'),
                                          content: Text(state is AdminError
                                              ? state.message
                                              : 'Failed to load device history'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: const Text('View Device History'),
                              ),
                              const SizedBox(height: 8),
                              // Action buttons for user management
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (user.status == 'pending') ...[
                                    ElevatedButton(
                                      onPressed: () => _confirmAction(
                                        context,
                                        'Approve',
                                        user.uid,
                                            () => context.read<AdminCubit>().approveUser(user.uid),
                                      ),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      child: const Text('Approve'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => _confirmAction(
                                        context,
                                        'Reject',
                                        user.uid,
                                            () => context.read<AdminCubit>().rejectUser(user.uid),
                                      ),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                  if (user.status == 'approve' || user.status == 'approved') ...[
                                    ElevatedButton(
                                      onPressed: () => _confirmAction(
                                        context,
                                        'Revoke Approval',
                                        user.uid,
                                            () => context.read<AdminCubit>().revokeApproval(user.uid),
                                      ),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                      child: const Text('Revoke Approval'),
                                    ),
                                  ],
                                  ElevatedButton(
                                    onPressed: () => _showRoleUpdateDialog(context, user.uid, user.role),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                    child: const Text('Update Role'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Refresh button to reload user list
      floatingActionButton: FloatingActionButton(
        onPressed: () => _filterStatus == 'Pending'
            ? context.read<AdminCubit>().fetchPendingUsers()
            : context.read<AdminCubit>().fetchAllUsers(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
*/
