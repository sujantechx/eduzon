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
            decoration: BoxDecoration(
              color: Colors.blue.shade100, // Placeholder color
              image: DecorationImage(
                image: course.imageUrl != null
                    ? NetworkImage(course.imageUrl!)
                    : const AssetImage('assets/images/course_placeholder.png') as ImageProvider,
                fit: BoxFit.fill,
              ),
            ),

          ),
        ),
      ),
    );
  }
}