// lib/presentation/screens/profile/profile_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduzon/data/models/courses_moddel.dart';
import 'package:eduzon/data/models/user_model.dart';
import 'package:eduzon/logic/auth/auth_bloc.dart';
import 'package:eduzon/logic/auth/auth_state.dart';
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

  bool _isEditing = false;
  bool _loadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initializeControllers(UserModel user) {
    _nameController.text = user.name;
    _addressController.text = user.address;
    _phoneController.text = user.phone;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final state = context.read<AuthCubit>().state;
      if (state is! Authenticated) return;

      context.read<AuthCubit>().updateProfile(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        college: '',
        branch: '',
        courseName: state.userModel.courseId ?? '',
      );

      setState(() => _isEditing = false);
    }
  }

  Widget _profileHeader(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    final initials = (user.name.isNotEmpty)
        ? user.name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : "U";
    final avatarRadius = 46.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white.withOpacity(0.15),
              child: Text(initials, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold,)),
            ),
            // CircleAvatar(
            //   radius: avatarRadius,
            //   backgroundColor: Colors.grey[200],
            //   backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
            //       ? NetworkImage(user.photoUrl!) as ImageProvider
            //       : null,
            //   child: (user.photoUrl == null || user.photoUrl!.isEmpty)
            //       ? const Icon(Icons.person, size: 48, color: Colors.grey)
            //       : null,
            // ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () => _showAvatarOptions(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(user.email, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(label: Text(user.role ?? 'Student')),
                  const SizedBox(width: 8),
                  // if (user.status != null) Chip(label: Text(user.status!)),
                ],
              )
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => context.read<AuthCubit>().signOut(),
          icon: const Icon(Icons.logout_outlined),
          tooltip: 'Sign out',
        ),
      ],
    );
  }

  Future<void> _showAvatarOptions(BuildContext context) async {
    // For now we only show dummy options. Connect with image picker / upload logic if needed.
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                // TODO: implement pick & upload
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gallery picker not implemented')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                // TODO: implement camera capture & upload
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera capture not implemented')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({required String label, required String value, IconData? icon}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: icon != null ? Icon(icon, size: 20) : null,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            _initializeControllers(state.userModel);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
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

          return LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 900 : double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _profileHeader(context, user),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Animated view / edit area
                      AnimatedCrossFade(
                        firstChild: _buildProfileView(context, user, isWide),
                        secondChild: _buildEditForm(context, user, isWide),
                        crossFadeState: _isEditing ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),

                      const SizedBox(height: 20),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => setState(() => _isEditing = !_isEditing),
                              icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
                              label: Text(_isEditing ? 'Cancel' : 'Edit Profile'),
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (!_isEditing)
                            OutlinedButton.icon(
                              onPressed: () {
                                // Navigate to my courses or payments
                                context.push(AppRoutes.myCourses);
                              },
                              icon: const Icon(Icons.book),
                              label: const Text('My Courses'),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                            )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, UserModel user, bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _infoTile(label: 'Name', value: user.name, icon: Icons.person),
                const Divider(),
                _infoTile(label: 'Email', value: user.email, icon: Icons.email),
                const Divider(),
                _infoTile(label: 'Phone', value: user.phone ?? '-', icon: Icons.phone),
                const Divider(),
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
                    return _infoTile(label: 'Course', value: courseName, icon: Icons.school);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(BuildContext context, UserModel user, bool isWide) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (v) => v == null || v.trim().isEmpty ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: user.email,
                readOnly: true,
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (v) => v == null || v.trim().isEmpty ? 'Phone cannot be empty' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (v) => v == null || v.trim().isEmpty ? 'Address cannot be empty' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        child: Text('Save Changes'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      _initializeControllers(user);
                      setState(() => _isEditing = false);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              )
            ],
          ),
        ),
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