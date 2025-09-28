// lib/data/models/chapter_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a single chapter document.
class ChapterModel {
  final String id;
  final String title;

  ChapterModel({required this.id, required this.title});

  factory ChapterModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChapterModel(
      id: doc.id,
      title: data['title'] ?? 'No Title',
    );
  }
}

