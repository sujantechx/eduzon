// lib/data/models/courses_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a single course document from the 'courses' collection.
class CoursesModel {
  final String id;
  final String title;
  final String description;

  CoursesModel({
    required this.id,
    required this.title,
    required this.description
  });

  // Factory to create a CoursesModel from a Firestore document snapshot.
  factory CoursesModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CoursesModel(
        id: doc.id,
        title: data['title'] ?? 'No Title',
        description: data['description'] ?? '');
  }
}