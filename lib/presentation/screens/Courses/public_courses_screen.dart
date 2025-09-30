// lib/presentation/screens/public/public_courses_screen.dart
import 'package:eduzon/presentation/screens/Courses/public_course_grid_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/courses_moddel.dart';
import '../../../data/repositories/admin_repository.dart';

/// The main entry screen for guest users, displaying a grid of all available courses.
class PublicCoursesScreen extends StatelessWidget {
  const PublicCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Courses'),
        actions: [
          // Add a button that takes users to the login screen
          TextButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      // Use a FutureBuilder to fetch the courses from the repository.
      body: FutureBuilder<List<CoursesModel>>(
        future: context.read<AdminRepository>().getCourses(),
        builder: (context, snapshot) {
          // Show a loading spinner while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show an error message if something went wrong
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Get the list of courses from the snapshot
          final courses = snapshot.data ?? [];
          if (courses.isEmpty) {
            return const Center(child: Text('No courses are available at the moment.'));
          }

          // Build the grid view
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: courses.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 courses per row
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final course = courses[index];
              return PublicCourseGridItem(
                course: course,
                onTap: () {
                  // When tapped, navigate to the detail page and pass the course object.
                  context.push(AppRoutes.courseDetail, extra: course);
                },
              );
            },
          );
        },
      ),
    );
  }
}