// lib/presentation/screens/splash/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/auth/auth_bloc.dart';
import '../../../logic/auth/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
//  This is safe
    Timer(const Duration(seconds:2), () {
      // First, check if the widget is still mounted
      if (!mounted) return;

      final authState = context.read<AuthCubit>().state;

      if (authState is Authenticated) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
           CircleAvatar(
             radius: 100,
             backgroundImage:AssetImage("assets/icons/Eduzon_logo.jpg"),),

            Text(
              'EDUZON',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
