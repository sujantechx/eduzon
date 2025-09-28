// lib/presentation/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../core/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  // 1. ADD CONTROLLERS for the new fields
  final _collegeController = TextEditingController();
  final _branchController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    // Remember to dispose the new controllers
    _collegeController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // 3. PASS NEW DATA to the register method in the cubit
      context.read<AuthCubit>().register(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        college: _collegeController.text,
        branch: _branchController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          developer.log('RegisterScreen received state: $state');
          if (state is Authenticated && state.userModel.status == 'pending') {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                    content: Text(
                        'Registration successful! Please wait for admin approval.'),
                    backgroundColor: Colors.green),
              );
            context.go(AppRoutes.pendingApproval);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red),
              );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration:  InputDecoration(
                        labelText: 'Full Name',
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue))
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Name cannot be empty' : null,
                  ),
                  const SizedBox(height: 16),

                  // 2. ADD FIELDS TO THE FORM
                  TextFormField(
                    controller: _collegeController,
                    decoration:  InputDecoration(labelText: 'College Name',
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue))),
                    validator: (value) =>
                    value!.isEmpty ? 'College cannot be empty' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _branchController,
                    decoration:  InputDecoration(labelText: 'Branch',
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue))),
                    validator: (value) =>
                    value!.isEmpty ? 'Branch cannot be empty' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration:  InputDecoration(labelText: 'Email',
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue))),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return 'Email cannot be empty';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration:  InputDecoration(labelText: 'Password',
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue))),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) return 'Password cannot be empty';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
              // The new, improved registration button with BlocConsumer
                  // The new, improved registration button with BlocConsumer
// You can now REMOVE the `bool _isLoading = false;` variable from your screen's state.

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        // The listener is ONLY for "side effects" like showing messages or navigating.
                        // We no longer need to call setState() here.
                        if (state is AuthError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                          );
                        }
                        if (state is RegistrationSuccessPendingApproval) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registration successful! Please wait for admin approval.'), backgroundColor: Colors.green),
                          );
                          // Navigate to the pending screen
                          context.go(AppRoutes.pendingApproval);
                        }
                      },
                      builder: (context, state) {
                        // The builder now controls everything about the button's appearance and behavior.
                        return ElevatedButton(
                          // The button is disabled ONLY when the state is AuthLoading.
                          onPressed: state is AuthLoading ? null : _register,
                          child: state is AuthLoading
                          // If loading, show the indicator and text.
                              ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
                              ),
                              SizedBox(width: 16),
                              Text("Registering..."),
                            ],
                          )
                          // Otherwise, show the normal text.
                              : const Text('Register'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


