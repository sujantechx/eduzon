// lib/data/models/chapter_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a single chapter document.
class ChapterModel {
  final String id;
  final String title;
  final int? chapterNumber; // Add this field


  ChapterModel({required this.id, required this.title,  this.chapterNumber});

  factory ChapterModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChapterModel(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      chapterNumber: data['chapterNumber'] as int?, // Initialize chapterNumber
    );
  }
}

