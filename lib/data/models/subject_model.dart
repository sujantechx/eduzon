// lib/data/models/subject_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a single subject document from the 'subjects' sub-collection.
class SubjectModel {
  final String id;
  final String title;
  final String description;

  SubjectModel({required this.id, required this.title,
    required this.description
  });

  // Factory to create a SubjectModel from a Firestore document snapshot.
  factory SubjectModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    if (data == null) {
      // Handle case where data is null
      throw Exception("Subject document data is null");
    }
    return SubjectModel(
      id: doc.id,
      title: (data['title'] as String?) ?? 'No Title',
      description: (data['description'] as String?) ?? '',
    );
  }
}

