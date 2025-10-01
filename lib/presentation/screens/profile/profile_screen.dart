// lib/presentation/screens/profile/profile_screen.dart
// ... all imports
import 'package:eduzon/data/models/user_model.dart';
import 'package:eduzon/logic/auth/auth_bloc.dart';
import 'package:eduzon/logic/auth/auth_state.dart';
import 'package:eduzon/data/models/courses_moddel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _coursesNameController = TextEditingController();

  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _coursesNameController.dispose();
    super.dispose();
  }

  void _initializeControllers(UserModel user) {
    _nameController.text = user.name;
    _addressController.text = user.address;
    _phoneController.text = user.phone;
    _coursesNameController.text = user.courseId;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = (context.read<AuthCubit>().state as Authenticated).userModel;
      context.read<AuthCubit>().updateProfile(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        college: '',
        branch: '',
        courseName: _coursesNameController.text.trim(),
      );
      setState(() => _isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
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
                          Text('Address: ${user.address}'),
                          Text('Phone: ${user.phone}'),
                          // Text(' ${user.role}'),
                          // const SizedBox(height: 8),
                          // Text('Status: ${user.status}'),
                          const SizedBox(height: 8),
                          // Correctly using FutureBuilder
                          FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance.collection('courses').doc(user.courseId).get(),
                            builder: (context, snapshot) {
                              String courseName = 'Loading...';
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                courseName = 'Loading...';
                              } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                                courseName = 'Not Found';
                              } else {
                                final courseData = snapshot.data!.data() as Map<String, dynamic>;
                                courseName = courseData['title'] ?? 'Unknown';
                              }
                              return Text('Course Name: $courseName');
                            },
                          ),
                          const SizedBox(height: 8),
                          // Text('Course id: ${user.courseId}'),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                _isEditing
                    ? Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue)),
                        ),
                        validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue)),
                        ),
                        controller: TextEditingController(text: user.email),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue)),
                        ),
                        validator: (v) => v!.isEmpty ? 'Address cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue)),
                        ),
                        validator: (v) => v!.isEmpty ? 'Phone cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                      // TextFormField(
                      //   decoration: InputDecoration(
                      //     labelText: 'Course Name',
                      //     enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                      //     focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue)),
                      //   ),
                      //   controller:_coursesNameController,
                      //   readOnly: true,
                      // ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _updateProfile,
                              child: const Text('Save'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              _initializeControllers(user);
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
              ],
            ),
          );
        },
      ),
    );
  }
}


/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
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
  final _addressController = TextEditingController();
  final _coursesNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _coursesNameController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  // This method sets the text for all controllers from the user model.
  void _initializeControllers(UserModel user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _addressController.text = user.address;
    _coursesNameController.text= user.courseId;
    _phoneController.text=user.phone as String;
  }

  // This method calls the cubit to save the updated profile data.
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().updateProfile(
        name: _nameController.text.trim(),
        // email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        courseId: _coursesNameController.text.trim(),
        phone: _phoneController.text.trim(), college: '', branch: '',

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
  Future<String> _fetchCourseName(String courseId) async {
    final doc = await FirebaseFirestore.instance.collection('courses').doc(courseId).get();
    if (doc.exists) {
      return doc.data()?['name'] ?? 'Unknown Course';
    }
    return 'Unknown Course';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        /// log out operation
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
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
                          Text('Address: ${user.address}'),
                          FutureBuilder<String>(
                            future: user.courseId != null && user.courseId.isNotEmpty
                                ? _fetchCourseName(user.courseId)
                                : Future.value('Unknown Course'),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return Text('Loading...');
                              return Text('Course Name: ${snapshot.data}');
                            },
                          ),

                          Text('Course id: ${user.courseId}'),
                          Text('Phone: ${user.phone}'),
                          const SizedBox(height: 8),
                          Text(' ${user.role}'),
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
                      TextFormField(
                        controller: _emailController,
                        decoration:  InputDecoration(
                          labelText: 'Email',
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue)),
                        ),
                        readOnly: true,

                      ),
                      const SizedBox(height: 16),
                      // ADDED: Form fields for college and branch
                      TextFormField(
                        controller: _addressController,
                        decoration:  InputDecoration(
                            labelText: 'Address',
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue))
                        ),
                        validator: (v) => v!.isEmpty ? 'Address cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration:  InputDecoration(
                            labelText: 'Phone',
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue))
                        ),
                        validator: (v) => v!.isEmpty ? 'Phone cannot be empty' : null,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller:_coursesNameController ,
                        decoration:  InputDecoration(
                            labelText: 'Course Name',
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue))
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 24
                      ),
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
              ],
            ),
          );
        },
      ),
    );
  }
}*/
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