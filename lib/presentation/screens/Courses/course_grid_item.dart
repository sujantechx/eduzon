// lib/presentation/widgets/admin/course_grid_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/courses_moddel.dart';
import '../../../logic/Courses/courses_cubit.dart';

/// A widget that displays a single course in a card format for the admin grid.
/// It includes actions for editing and deleting the course.
class CourseGridItem extends StatelessWidget {
  final CoursesModel course;
  final VoidCallback onEdit; // Callback to open the edit dialog

  const CourseGridItem({
    super.key,
    required this.course,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      clipBehavior: Clip.antiAlias, // Ensures the ink splash is contained
      child: InkWell(
        onTap: () {
          // TODO: Navigate to the subjects list screen for this course
          print('Tapped on course: ${course.title}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Title and Menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Popup menu for Edit and Delete actions
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, course);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Course Description
              Expanded(
                child: Text(
                  course.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
              const Spacer(),

              // Course ID at the bottom
              Text(
                'ID: ${course.id}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to show a confirmation dialog before deleting.
  void _showDeleteConfirmation(BuildContext context, CoursesModel course) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Course?'),
        content: Text(
            'Are you sure you want to delete "${course.title}"? This will not delete its sub-collections but cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              // Call the cubit to delete the course
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