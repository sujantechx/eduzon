// lib/data/repositories/content_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chapter_model.dart';
import '../models/subject_model.dart';
import '../models/video_model.dart';

// Handles all content management operations (Subjects, Chapters, Videos).
class ContentRepository {
  final FirebaseFirestore _firestore;

  // The main course document we are working with.
  final DocumentReference _courseDoc;

  ContentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _courseDoc = FirebaseFirestore.instance.collection('courses').doc('ojee_2025_2026_batch');

  // Fetches a real-time stream of subjects for the course.
  Stream<List<SubjectModel>> getSubjects() {
    return _courseDoc.collection('subjects').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SubjectModel.fromSnapshot(doc)).toList();
    });
  }
  Stream<List<ChapterModel>> getChapters({required String subjectId}) {
    return _courseDoc.collection('subjects').doc(subjectId).collection('chapters').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ChapterModel.fromSnapshot(doc)).toList();
    });
  }

  // Adds a new subject document to the 'subjects' sub-collection.
  Future<void> addSubject({required String title}) async {
    try {
      await _courseDoc.collection('subjects').add({
        'title': title,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add subject: $e');
    }
  }

  // NEW: Updates an existing subject's title.
  Future<void> updateSubject({required String subjectId, required String newTitle}) async {
    try {
      await _courseDoc.collection('subjects').doc(subjectId).update({'title': newTitle});
    } catch (e) {
      throw Exception('Failed to update subject: $e');
    }
  }

  // NEW: Deletes a subject document. This will also delete all its sub-collections (chapters, videos).
  Future<void> deleteSubject({required String subjectId}) async {
    try {
      // NOTE: This is a simple delete. For production, you might want a Cloud Function
      // to recursively delete all sub-collections to avoid orphaned data.
      await _courseDoc.collection('subjects').doc(subjectId).delete();
    } catch (e) {
      throw Exception('Failed to delete subject: $e');
    }
  }
  //=========== Chapter Methods ===========


  Future<void> addChapter({required String subjectId, required String title}) async {
    try {
      await _courseDoc.collection('subjects').doc(subjectId).collection('chapters').add({
        'title': title,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add chapter: $e');
    }
  }

  Future<void> updateChapter({required String subjectId, required String chapterId, required String newTitle}) async {
    try {
      await _courseDoc.collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).update({'title': newTitle});
    } catch (e) {
      throw Exception('Failed to update chapter: $e');
    }
  }

  Future<void> deleteChapter({required String subjectId, required String chapterId}) async {
    try {
      await _courseDoc.collection('subjects').doc(subjectId).collection(
          'chapters').doc(chapterId).delete();
    } catch (e) {
      throw Exception('Failed to delete chapter: $e');
    }
  }
  //Video Methods

  // Fetches a real-time stream of videos for a given chapter.
  Stream<List<VideoModel>> getVideos({required String subjectId, required String chapterId}) {
    return _courseDoc
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .doc(chapterId)
        .collection('videos')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => VideoModel.fromSnapshot(doc)).toList();
    });
  }
}

