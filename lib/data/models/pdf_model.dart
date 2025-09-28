// lib/data/models/video_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Represents a single video document from the 'videos' sub-collection.
class PdfModel {
  final String id;
  final String title;
  final String url; // The YouTube video ID

  PdfModel({
    required this.id,
    required this.title,
    required this.url,
  });

  // Factory to create a VideoModel from a Firestore document snapshot.
  factory PdfModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PdfModel(
      id: doc.id,
      title: data['title'] ?? 'No Title',
      url: data['url'] ?? '',
    );
  }
}
