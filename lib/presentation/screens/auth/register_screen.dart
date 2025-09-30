// lib/presentation/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../core/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  // It now receives the courseId from the payment flow.
  final String courseId;
  const RegisterScreen({super.key, required this.courseId});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  // ✅ UPDATED: Controllers now match the UserModel
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _paymentIdController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _paymentIdController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        paymentId: _paymentIdController.text,
        courseId: widget.courseId, // Use the courseId passed to the screen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Your Account')),
      // Use one BlocConsumer for the whole screen
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          developer.log('RegisterScreen received state: $state');
          if (state is RegistrationSuccessPendingApproval) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Registration successful! Please wait for admin approval.'),
                  backgroundColor: Colors.green),
            );
            context.go(AppRoutes.pendingApproval);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null,
                  ),
                  const SizedBox(height: 16),

                  // ✅ UPDATED: Form fields now match the UserModel
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Address cannot be empty' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Phone number cannot be empty' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? 'Email cannot be empty' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                    obscureText: true,
                    validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _paymentIdController,
                    decoration: const InputDecoration(labelText: 'Payment Transaction ID', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Payment ID cannot be empty' : null,
                  ),
                  const SizedBox(height: 24),

                  // ✅ UPDATED: A single, clean button driven by the BLoC state
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading ? null : _register,
                      child: state is AuthLoading
                          ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0)),
                          SizedBox(width: 16),
                          Text("Registering..."),
                        ],
                      )
                          : const Text('Register'),
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