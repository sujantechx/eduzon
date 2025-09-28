import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../core/routes/app_routes.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';
import 'dart:developer' as developer;


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        final androidInfo = await deviceInfo.androidInfo;
        final deviceId = androidInfo.id;
        final deviceName = androidInfo.model;
        final deviceType = 'android';

        developer.log('Initiating login for email: ${_emailController.text.trim()}');
        if (mounted) {
          await context.read<AuthCubit>().login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            deviceId: deviceId,
            deviceName: deviceName,
            deviceType: deviceType,
          );
        }
      } catch (e) {
        developer.log('Login error: $e', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().contains('invalid-credential') ? 'Invalid email or password.' : 'Login failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          developer.log('LoginScreen state: $state');
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is Authenticated) {
            developer.log('Login successful, relying on router redirect');
            // Router handles navigation
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration:  InputDecoration(
                      labelText: 'Email',
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue))
                  ),
                  validator: (value) => value!.isEmpty ? 'Email is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration:  InputDecoration(
                      labelText: 'Password',
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.blue))
                  ),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Password is required' : null,
                ),
                const SizedBox(height: 16),
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
                          const SnackBar(content: Text('Login successful'), backgroundColor: Colors.green),
                        );
                        // Navigate to the pending screen
                        context.go(AppRoutes.pendingApproval);
                      }
                    },
                    builder: (context, state) {
                      // The builder now controls everything about the button's appearance and behavior.
                      return ElevatedButton(
                        // The button is disabled ONLY when the state is AuthLoading.
                        onPressed: state is AuthLoading ? null : _login,
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
                            Text("Login..."),
                          ],
                        )
                        // Otherwise, show the normal text.
                            : const Text('Login'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go(AppRoutes.register),
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}