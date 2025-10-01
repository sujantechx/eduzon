// lib/presentation/screens/public/course_detail_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/courses_moddel.dart';

/// A page that shows the details of a specific course to a guest user.
class CourseDetailPage extends StatelessWidget {
  // This page will receive the course details from the previous screen.
  final CoursesModel course;
  final String? imageUrl;

  const CourseDetailPage({super.key, required this.course, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(
                    course.imageUrl ??
                        'https://via.placeholder.com/150', // Fallback image
                  ), fit: BoxFit.fill, ),

                ),
              ),

            // Course Title
            Text(
              course.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Course Description
            Text(
              course.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(), // Pushes the price and button to the bottom

            // Course Price
            Center(
              child: Text(
                'Price: ₹${course.price}', // Assuming your model has a 'price' field
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.green),
              ),
            ),
            const SizedBox(height: 16),

            // Buy Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // When clicked, navigate to the QR payment page
                  // and pass the course object along.
                  context.push(AppRoutes.qrPayment, extra: course);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Buy Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}