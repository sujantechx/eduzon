// lib/presentation/widgets/public/public_course_grid_item.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/models/courses_moddel.dart';

/// A widget that displays a single course in a card format for the public course list.
class PublicCourseGridItem extends StatelessWidget {
  final CoursesModel course;
  final VoidCallback onTap; // Callback for when the item is tapped

  const PublicCourseGridItem({
    super.key,
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap, // Trigger the navigation callback
        child: GridTile(
          // You can add a course image here later using Stack
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            title: Text(
              course.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Price: ₹${course.price}', // Assuming your model has a price field
              textAlign: TextAlign.center,
            ),
          ),
          child: Container(
            color: Colors.blue.shade100, // Placeholder color
            // TODO: Add a course thumbnail image here
            // child: Image.network(course.thumbnailUrl, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}