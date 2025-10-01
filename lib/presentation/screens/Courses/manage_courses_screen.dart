// lib/presentation/screens/admin/manage_courses_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduzon/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/courses_moddel.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../logic/Courses/courses_cubit.dart';
import '../../../logic/Courses/courses_state.dart';
import '../admin/admin_subjects_page.dart';


/// A screen for admins to view, add, edit, and delete courses.
class ManageCoursesScreen extends StatelessWidget {
  const ManageCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CoursesCubit(
        adminRepository: context.read<AdminRepository>(),
      )..loadCourses(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Courses'),
        ),
        body: BlocConsumer<CoursesCubit, CoursesState>(
          listener: (context, state) {
            if (state is AdminCoursesSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            } else if (state is AdminCoursesError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            if (state is AdminCoursesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AdminCoursesLoaded) {
              if (state.courses.isEmpty) {
                return const Center(child: Text('No courses found. Add one!'));
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: state.courses.length,
                itemBuilder: (context, index) {
                  final course = state.courses[index];
                  // UPDATED: We now call our local _buildCourseGridItem method.
                  return _buildCourseGridItem(context, course);
                },
              );
            }
            return const Center(child: Text('Failed to load courses.'));
          },
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () => _showAddOrEditCourseDialog(context),
              tooltip: 'Add Course',
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  // =======================================================================
  // == MERGED WIDGET: The UI from CourseGridItem is now here. ==
  // =======================================================================
  Widget _buildCourseGridItem(BuildContext context, CoursesModel course) {
    return Card(
      elevation: 4.0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // ✅ NAVIGATION ADDED HERE
      /*  onTap: () {
          // Navigate to the subjects page, passing the course ID.
          context.push(AppRoutes.AdminSubjects, extra: course.id);
        },*/
        onTap: () {
          // Add a print statement here to be 100% sure the ID is valid before navigating.
          print('Navigating to subjects for course ID: ${course.id}');

          // Make sure you are passing the non-empty course.id to the next screen.
         context.push(AppRoutes.AdminSubjects, extra: course.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddOrEditCourseDialog(context, course: course);
                      } else if (value == 'delete') {
                        _showDeleteConfirmationDialog(context, course);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                      PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  course.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
              const Spacer(),
              Text(
                'ID: ${course.id}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =======================================================================
  // == HELPER METHODS: The dialogs are now here. ==
  // =======================================================================

  void _showAddOrEditCourseDialog(BuildContext context, {CoursesModel? course}) {
    final isEditing = course != null;
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: course?.title ?? '');
    final descController = TextEditingController(text: course?.description ?? '');
    final priceController =TextEditingController(text: course?.price.toString() ?? '');
    final imageUrlController =TextEditingController(text: course?.imageUrl ?? '');
    final createdAtController =TextEditingController(text: course?.createdAt.toDate().toString() ?? '');
    final updatedAtController =TextEditingController(text: course?.updatedAt.toDate().toString() ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Course' : 'Add New Course'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Course Title'),
                  validator: (value) => value!.isEmpty ? 'Title cannot be empty' : null,
                ),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Course Description'),
                  validator: (value) => value!.isEmpty ? 'Description cannot be empty' : null,
                ),
               TextField(
                 controller: priceController,
                  decoration: const InputDecoration(labelText: 'Course Price'),
                  keyboardType: TextInputType.number,
               ),
                TextField(
                  controller: imageUrlController,
                    decoration: const InputDecoration(labelText: 'Course Image URL'),
                    keyboardType: TextInputType.url,
                ),
                TextField(
                  controller: createdAtController,
                  decoration: const InputDecoration(labelText: 'Created At'),
                  readOnly: true,
                ),
                TextField(
                  controller: updatedAtController,
                  decoration: const InputDecoration(labelText: 'Updated At'),
                  readOnly: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final cubit = context.read<CoursesCubit>();
                  if (isEditing) {
                    cubit.updateCourse(
                      courseId: course.id,
                      data: {
                        'title': titleController.text.trim(),
                        'description': descController.text.trim(),
                        'price': num.tryParse(priceController.text.trim()) ?? 0,
                        'imageUrl': imageUrlController.text.trim(),
                        'updatedAt': FieldValue.serverTimestamp(),
                      },
                    );
                  } else {
                    cubit.addCourse(
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                    );
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, CoursesModel course) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Course?'),
        content: Text('Are you sure you want to delete "${course.title}"? This will not delete its sub-collections but cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              context.read<CoursesCubit>().deleteCourse(courseId: course.id);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}