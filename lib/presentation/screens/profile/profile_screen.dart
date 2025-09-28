// lib/presentation/screens/profile/profile_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  // ADDED: Controllers for college and branch
  final _collegeController = TextEditingController();
  final _branchController = TextEditingController();

  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _collegeController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  // This method sets the text for all controllers from the user model.
  void _initializeControllers(UserModel user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _collegeController.text = user.college;
    _branchController.text = user.branch;
  }

  // This method calls the cubit to save the updated profile data.
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().updateProfile(
        name: _nameController.text.trim(),
        // email: _emailController.text.trim(),
        college: _collegeController.text.trim(),
        branch: _branchController.text.trim(),
      );
      // Hide the form after saving
      setState(() => _isEditing = false);
    }
  }
  Future<List<Map<String, dynamic>>> _fetchDeviceHistory(String uid) async {

    final snapshot = await FirebaseFirestore.instance

        .collection('users')

        .doc(uid)

        .collection('devices')

        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
       /// log out operation
/*
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
*/
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            _initializeControllers(state.userModel);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is Unauthenticated) {
            context.go(AppRoutes.login);
          }
        },
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.userModel;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Profile',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                // Display user info when not editing
                if (!_isEditing)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${user.name}', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text('Email: ${user.email}'),
                          const SizedBox(height: 8),
                          // ADDED: Display college and branch
                          Text('College: ${user.college}'),
                          const SizedBox(height: 8),
                          Text('Branch: ${user.branch}'),
                          const SizedBox(height: 8),
                          Text('Role: ${user.role}'),
                          const SizedBox(height: 8),
                          Text('Status: ${user.status}'),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Show the form when editing, or the "Edit Profile" button when not
                _isEditing
                    ? Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration:  InputDecoration(
                            labelText: 'Name',
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue))                        ),
                        validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                      // TextFormField(
                      //   controller: _emailController,
                      //   decoration:  InputDecoration(
                      //       labelText: 'Email',
                      //       enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                      //       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue)),
                      //       ),
                      //   keyboardType: TextInputType.emailAddress,
                      //   validator: (v) => v!.isEmpty ? 'Email cannot be empty' : null,
                      // ),
                      const SizedBox(height: 16),
                      // ADDED: Form fields for college and branch
                      TextFormField(
                        controller: _collegeController,
                        decoration:  InputDecoration(
                            labelText: 'College',
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue))
                        ),
                        validator: (v) => v!.isEmpty ? 'College cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _branchController,
                        decoration:  InputDecoration(
                            labelText: 'Branch',
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue))
                        ),
                        validator: (v) => v!.isEmpty ? 'Branch cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _updateProfile, // Button is now functional
                              child: const Text('Save'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              _initializeControllers(user); // Reset changes on cancel
                              setState(() => _isEditing = false);
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    : ElevatedButton(
                  onPressed: () => setState(() => _isEditing = true),
                  child: const Text('Edit Profile'),
                ),

              ///device hestor
              /*  Text(
                  'Device History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchDeviceHistory(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Error loading device history');
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final devices = snapshot.data!;
                    if (devices.isEmpty) {
                      return const Text('No device history available');
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        return ListTile(
                          title: Text(device['name'] ?? 'Unknown Device'),
                          subtitle: Text(
                            'Type: ${device['type']}\n'
                                'Token: ${device['token']}\n'
                                'Login: ${device['loginTime'].toDate()}\n'
                                'Logout: ${device['logoutTime']?.toDate() ?? 'Active'}',
                          ),
                        );
                      },
                    );
                  },
                ),*/
              ],
            ),
          );
        },
      ),
    );
  }
}