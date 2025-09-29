import 'package:eduzon/presentation/screens/Courses/manage_courses_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../logic/auth/auth_bloc.dart';
import 'admin_subjects_page.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.manage_accounts),
                      title: const Text('Manage Student Registrations'),
                      subtitle: const Text('Approve or reject new students'),
                      onTap: () {
                        context.push(AppRoutes.manageStudents);
                      },
                    ),
                  ),
                  const Divider(),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.video_library_outlined),
                      title: const Text('Manage Course Content'),
                      subtitle: const Text('courses,subjects,chapters,videos, and PDFs'),
                      onTap: (){
                        // context.pushNamed(AppRoutes.AdminSubjects);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ManageCoursesScreen(),));
                      },
                    ),
                  ),
                  /*Card(
                    child: ListTile(
                      leading: const Icon(Icons.video_library_outlined),
                      title: const Text('Manage Course Content'),
                      subtitle: const Text('Add subjects, chapters, videos, and PDFs'),
                      onTap: (){
                        // context.pushNamed(AppRoutes.AdminSubjects);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminSubjectsPage(),));
                      },
                    ),
                  ),*/
                  // Placeholder for future admin features
                  const Divider(),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Other Settings'),
                      subtitle: const Text('Coming soon...'),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Feature coming soon!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}