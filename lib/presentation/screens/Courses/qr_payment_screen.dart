// lib/presentation/screens/public/qr_payment_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/courses_moddel.dart';

/// A page that displays the QR code for payment.
class QrPaymentScreen extends StatelessWidget {
  // This page receives the course details from the CourseDetailPage.
  final CoursesModel course;

  const QrPaymentScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions to the user
            Text(
              'Scan the QR Code to Pay ₹${course.price}',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Your QR Code Image
            // Make sure you have 'payment_qr.png' in your 'assets/images/' folder.
            Image.asset('assets/images/payment_qr.jpg'),
            const SizedBox(height: 20),

            // More detailed instructions
            const Text(
              'After paying, copy the Transaction ID. You will need to enter it on the next screen.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5, color: Colors.grey),
            ),
            const Spacer(),

            // Button to proceed to registration
            ElevatedButton(
              onPressed: () {
                // Navigate to the register screen you already built.
                // Pass the ID of the course they are paying for.
                context.push(AppRoutes.register, extra: course.id);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('I Have Paid, Continue to Register'),
            ),
          ],
        ),
      ),
    );
  }
}