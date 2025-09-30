// lib/data/models/courses_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CoursesModel {
  final String id;
  final String title;
  final String description;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final num price;

  CoursesModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CoursesModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CoursesModel(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      description: data['description'] ?? '',
      price: data['price'] ?? 0,
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }
}
