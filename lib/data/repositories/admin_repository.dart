
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduzon/data/models/question_model.dart';
import 'package:eduzon/data/models/video_model.dart';
import 'package:eduzon/data/models/subject_model.dart';
import 'package:eduzon/data/models/chapter_model.dart';
import 'package:eduzon/data/models/pdf_model.dart';
import 'dart:developer' as developer;

import '../models/courses_moddel.dart';
import '../models/result_model.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper to get the base collection reference
  CollectionReference _coursesRef() => _firestore.collection('courses');

  // Helper to get the questions collection reference
  CollectionReference _questionsRef({
    required String courseId,
    required String subjectId,
    required String chapterId,
  }) {
    return _coursesRef()
        .doc(courseId)
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .doc(chapterId)
        .collection('questions');
  }

  // Helper to get the videos collection reference
  CollectionReference _videosRef({
    required String courseId,
    required String subjectId,
    required String chapterId,
  }) {
    return _coursesRef()
        .doc(courseId)
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .doc(chapterId)
        .collection('videos');
  }

  // Helper to get the PDFs collection reference
  CollectionReference _pdfsRef({
    required String courseId,
    required String subjectId,
    required String chapterId,
  }) {
    return _coursesRef()
        .doc(courseId)
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .doc(chapterId)
        .collection('pdfs');
  }

  /// Fetches a list of all courses.
  Future<List<CoursesModel>> getCourses() async {
    try {
      final snapshot = await _coursesRef().get();
      return snapshot.docs.map((doc) => CoursesModel.fromSnapshot(doc)).toList();
    } catch (e) {
      developer.log("Error fetching courses: $e");
      throw Exception('Failed to load courses.');
    }
  }

  /// Fetches all subjects for a given course.
  Future<List<SubjectModel>> getSubjects({required String courseId}) async {
    try {
      final snapshot = await _coursesRef().doc(courseId).collection('subjects').get();
      return snapshot.docs.map((doc) => SubjectModel.fromSnapshot(doc)).toList();
    } catch (e) {
      developer.log("Error fetching subjects: $e");
      throw Exception('Failed to load subjects.');
    }
  }

  /// Fetches all chapters for a given subject.
  Future<List<ChapterModel>> getChapters(
      {required String courseId, required String subjectId}) async {
    try {
      final snapshot = await _coursesRef()
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .get();
      return snapshot.docs.map((doc) => ChapterModel.fromSnapshot(doc)).toList();
    } catch (e) {
      developer.log("Error fetching chapters: $e");
      throw Exception('Failed to load chapters.');
    }
  }

  /// Fetches all videos for a given chapter.
  Future<List<VideoModel>> getVideos(
      {required String courseId,
        required String subjectId,
        required String chapterId}) async {
    try {
      final snapshot = await _videosRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .get();
      return snapshot.docs
          .map((doc) => VideoModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      developer.log("Error fetching videos: $e");
      throw Exception('Failed to load videos.');
    }
  }

  /// Fetches all PDFs for a given chapter.
  Future<List<PdfModel>> getPdfs(
      {required String courseId,
        required String subjectId,
        required String chapterId}) async {
    try {
      final snapshot = await _pdfsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .get();
      return snapshot.docs
          .map((doc) => PdfModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      developer.log("Error fetching PDFs: $e");
      throw Exception('Failed to load PDFs.');
    }
  }

  /// Fetches all questions for a specific chapter.
  Future<List<QuestionModel>> getQuestions({
    required String courseId,
    required String subjectId,
    required String chapterId,
  }) async {
    try {
      final snapshot = await _questionsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .get();
      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log("Error fetching questions: $e");
      throw Exception('Failed to load questions.');
    }
  }

  /// Adds a new course document.
  Future<void> addCourse({required String title, required String description}) async {
    try {
      await _coursesRef().add({
        'title': title,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'price': 0, // Default price
        'imageUrl': null, // Default image URL
      });
    } catch (e) {
      developer.log("Error adding course: $e");
      throw Exception('Failed to add course.');
    }
  }

  /// Adds a new subject to a course.
  Future<void> addSubject(
      {required String courseId,
        required String title,
        required String description}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').add({
        'title': title,
        'description': description,
      });
    } catch (e) {
      developer.log("Error adding subject: $e");
      throw Exception('Failed to add subject.');
    }
  }

  /// Adds a new chapter to a subject.
  Future<void> addChapter(
      {required String courseId, required String subjectId, required String title}) async {
    try {
      await _coursesRef()
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .add({
        'title': title,
      });
    } catch (e) {
      developer.log("Error adding chapter: $e");
      throw Exception('Failed to add chapter.');
    }
  }

  /// Adds a new video to a chapter.
  Future<void> addVideo(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required String title,
        required String videoId,
        required String duration}) async {
    try {
      await _videosRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .add({
        'title': title,
        'videoId': videoId,
        'duration': duration,
      });
    } catch (e) {
      developer.log("Error adding video: $e");
      throw Exception('Failed to add video.');
    }
  }

  /// Adds a new PDF to a chapter.
  Future<void> addPdf(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required String title,
        required String url}) async {
    try {
      await _pdfsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .add({
        'title': title,
        'url': url,
      });
    } catch (e) {
      developer.log("Error adding PDF: $e");
      throw Exception('Failed to add PDF.');
    }
  }

  /// Adds a new question to a specific chapter.
  Future<void> addQuestion(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required QuestionModel question}) async {
    try {
      await _questionsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .add(question.toFirestore());
    } catch (e) {
      developer.log("Error adding question: $e");
      throw Exception('Failed to add question.');
    }
  }

  /// Updates an existing course's data.
  Future<void> updateCourse(
      {required String courseId, required Map<String, dynamic> data}) async {
    try {
      await _coursesRef().doc(courseId).update(data);
    } catch (e) {
      developer.log("Error updating course: $e");
      throw Exception('Failed to update course.');
    }
  }

  /// Updates an existing subject's data.
  Future<void> updateSubject(
      {required String courseId,
        required String subjectId,
        required Map<String, dynamic> data}) async {
    try {
      await _coursesRef()
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .update(data);
    } catch (e) {
      developer.log("Error updating subject: $e");
      throw Exception('Failed to update subject.');
    }
  }

  /// Updates an existing chapter's data.
  Future<void> updateChapter(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required Map<String, dynamic> data}) async {
    try {
      await _coursesRef()
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .doc(chapterId)
          .update(data);
    } catch (e) {
      developer.log("Error updating chapter: $e");
      throw Exception('Failed to update chapter.');
    }
  }

  /// Updates an existing video's data.
  Future<void> updateVideo(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required String videoId,
        required Map<String, dynamic> data}) async {
    try {
      await _videosRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .doc(videoId)
          .update(data);
    } catch (e) {
      developer.log("Error updating video: $e");
      throw Exception('Failed to update video.');
    }
  }

  /// Updates an existing PDF's data.
  Future<void> updatePdf(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required String pdfId,
        required Map<String, dynamic> data}) async {
    try {
      await _pdfsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .doc(pdfId)
          .update(data);
    } catch (e) {
      developer.log("Error updating PDF: $e");
      throw Exception('Failed to update PDF.');
    }
  }

  /// Updates an existing question.
  Future<void> updateQuestion(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required QuestionModel question}) async {
    try {
      await _questionsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .doc(question.id)
          .update(question.toFirestore());
    } catch (e) {
      developer.log("Error updating question: $e");
      throw Exception('Failed to update question.');
    }
  }

  /// Deletes a course document.
  Future<void> deleteCourse({required String courseId}) async {
    try {
      await _coursesRef().doc(courseId).delete();
    } catch (e) {
      developer.log("Error deleting course: $e");
      throw Exception('Failed to delete course.');
    }
  }

  /// Deletes a specific video.
  Future<void> deleteVideo(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required String videoId}) async {
    try {
      await _videosRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .doc(videoId)
          .delete();
    } catch (e) {
      developer.log("Error deleting video: $e");
      throw Exception('Failed to delete video.');
    }
  }

  /// Deletes a specific PDF.
  Future<void> deletePdf(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required String pdfId}) async {
    try {
      await _pdfsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .doc(pdfId)
          .delete();
    } catch (e) {
      developer.log("Error deleting PDF: $e");
      throw Exception('Failed to delete PDF.');
    }
  }

  /// Deletes a specific question.
  Future<void> deleteQuestion(
      {required String courseId,
        required String subjectId,
        required String chapterId,
        required String questionId}) async {
    try {
      await _questionsRef(
          courseId: courseId, subjectId: subjectId, chapterId: chapterId)
          .doc(questionId)
          .delete();
    } catch (e) {
      developer.log("Error deleting question: $e");
      throw Exception('Failed to delete question.');
    }
  }

  /// Deletes a chapter.
  Future<void> deleteChapter(
      {required String courseId,
        required String subjectId,
        required String chapterId}) async {
    try {
      await _coursesRef()
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .doc(chapterId)
          .delete();
    } catch (e) {
      developer.log("Error deleting chapter: $e");
      throw Exception('Failed to delete chapter.');
    }
  }

  /// Deletes a subject.
  Future<void> deleteSubject(
      {required String courseId, required String subjectId}) async {
    try {
      await _coursesRef()
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .delete();
    } catch (e) {
      developer.log("Error deleting subject: $e");
      throw Exception('Failed to delete subject.');
    }
  }

  Future<void>submitResult({required ResultModel result}) async {
    try {
      await _firestore.collection('results').add(result.toFirestore());
    } catch (e) {
      print("Error submitting result: $e");
      throw Exception('Failed to submit result.');
    }
  }
  Future<ResultModel> getPreviousResult({required String userId, required String chapterId}) async {
    try {
      final querySnapshot = await _firestore
          .collection('results')
          .where('userId', isEqualTo: userId)
          .where('chapterId', isEqualTo: chapterId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No previous results found.');
      }

      return ResultModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      print("Error fetching previous result: $e");
      throw Exception('Failed to fetch previous result.');
    }
  }
}


/*
// lib/data/repositories/admin_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduzon/data/models/question_model.dart';
import '../models/chapter_model.dart';
import '../models/courses_moddel.dart';
import '../models/pdf_model.dart';
import '../models/result_model.dart';
import '../models/subject_model.dart';
import '../models/video_model.dart';
// Handles all content management operations (Subjects, Chapters, Videos).
*/
/*
class ContentRepository {
  final FirebaseFirestore _firestore;
  // The main course document we are working with.
  final DocumentReference _courseDoc;

  ContentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _courseDoc = FirebaseFirestore.instance.collection('courses').doc('ojee_2025_2026_batch');
*/
/*



class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Helper to get the base collection reference
  CollectionReference _coursesRef() => _firestore.collection('courses');

  // --- FETCH (READ) OPERATIONS ---
  // --- COURSE MANAGEMENT (CREATE, READ, UPDATE, DELETE) ---
  /// Fetches a list of all courses.
  Future<List<CoursesModel>> getCourses() async {
    try {
      final snapshot = await _coursesRef().get();
      return snapshot.docs.map((doc) => CoursesModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print("Error fetching courses: $e");
      throw Exception('Failed to load courses.');
    }
  }

  /// Fetches all subjects for a given course.
  Future<List<SubjectModel>> getSubjects({required String courseId}) async {
    try {
      print('Attempting to fetch subjects for course ID: $courseId');

      final snapshot = await _coursesRef().doc(courseId).collection('subjects').get();
      print('Successfully found ${snapshot.docs.length} subjects.');

      return snapshot.docs.map((doc) => SubjectModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print("Error fetching subjects: $e");
      throw Exception('Failed to load subjects.');
    }
  }

  /// Fetches all chapters for a given subject.
  Future<List<ChapterModel>> getChapters({required String courseId, required String subjectId}) async {
    try {
      final snapshot = await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').get();
      return snapshot.docs.map((doc) => ChapterModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print("Error fetching chapters: $e");
      throw Exception('Failed to load chapters.');
    }
  }

  /// Fetches all videos for a given chapter.
  Future<List<VideoModel>> getVideos({required String courseId, required String subjectId, required String chapterId}) async {
    try {
      final snapshot = await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).collection('videos').get();
      return snapshot.docs.map((doc) => VideoModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print("Error fetching videos: $e");
      throw Exception('Failed to load videos.');
    }
  }

  /// Fetches all PDFs for a given chapter.
  Future<List<PdfModel>> getPdfs({required String courseId, required String subjectId, required String chapterId}) async {
    try {
      final snapshot = await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).collection('pdfs').get();
      return snapshot.docs.map((doc) => PdfModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print("Error fetching PDFs: $e");
      throw Exception('Failed to load PDFs.');
    }
  }
  Future<List<QuestionModel>>getQuestions({required String courseId, required String subjectId, required String chapterId}) async {
    try {
      final snapshot = await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).collection('questions').get();
      return snapshot.docs.map((doc) => QuestionModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching questions: $e");
      throw Exception('Failed to load questions.');
    }
  }
  // --- ADD (CREATE) OPERATIONS ---
  /// Adds a new course document.
  Future<void> addCourse({required String title, required String description}) async {
    try {
      await _coursesRef().add({
        'title': title,
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'price': 0, // Default price
        'imageUrl': null, // Default image URL
      });
    } catch (e) {
      print("Error adding course: $e");
      throw Exception('Failed to add course.');
    }
  }

  /// Adds a new subject to a course.
  Future<void> addSubject({required String courseId, required String title, required String description}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').add({
        'title': title,
        'description': description,
      });
    } catch (e) {
      print("Error adding subject: $e");
      throw Exception('Failed to add subject.');
    }
  }

  /// Adds a new chapter to a subject.
  Future<void> addChapter({required String courseId, required String subjectId, required String title}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').add({
        'title': title,
      });
    } catch (e) {
      print("Error adding chapter: $e");
      throw Exception('Failed to add chapter.');
    }
  }

  /// Adds a new video to a chapter.
  Future<void> addVideo({required String courseId, required String subjectId, required String chapterId, required String title, required String videoId, required String duration}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).collection('videos').add({
        'title': title,
        'videoId': videoId,
        'duration': duration,
      });
    } catch (e) {
      print("Error adding video: $e");
      throw Exception('Failed to add video.');
    }
  }

  /// Adds a new PDF to a chapter.
  Future<void> addPdf({required String courseId, required String subjectId, required String chapterId, required String title, required String url}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).collection('pdfs').add({
        'title': title,
        'url': url,
      });
    } catch (e) {
      print("Error adding PDF: $e");
      throw Exception('Failed to add PDF.');
    }
  }
  /// Adds a new question to a chapter.
  Future<void> addQuestion({required String courseId, required String subjectId, required String chapterId, required QuestionModel question}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).collection('questions').add(question.toFirestore());
    } catch (e) {
      print("Error adding question: $e");
      throw Exception('Failed to add question.');
    }
  }
  // --- UPDATE OPERATIONS ---
  /// Updates an existing course's data.
  Future<void> updateCourse({required String courseId, required Map<String, dynamic> data}) async {
    try {
      await _coursesRef().doc(courseId).update(data);
    } catch (e) {
      print("Error updating course: $e");
      throw Exception('Failed to update course.');
    }
  }

  /// Updates an existing subject's data.
  Future<void> updateSubject({required String courseId, required String subjectId, required Map<String, dynamic> data}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).update(data);
    } catch (e) {
      print("Error updating subject: $e");
      throw Exception('Failed to update subject.');
    }
  }

  /// Updates an existing chapter's data.
  Future<void> updateChapter({required String courseId, required String subjectId, required String chapterId, required Map<String, dynamic> data}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).update(data);
    } catch (e) {
      print("Error updating chapter: $e");
      throw Exception('Failed to update chapter.');
    }
  }

  /// Updates an existing video's data.
  Future<void> updateVideo({required String courseId, required String subjectId, required String chapterId, required String videoId, required Map<String, dynamic> data}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).collection('videos').doc(videoId).update(data);
    } catch (e) {
      print("Error updating video: $e");
      throw Exception('Failed to update video.');
    }
  }

  /// Updates an existing PDF's data.
  Future<void> updatePdf({required String courseId, required String subjectId, required String chapterId, required String pdfId, required Map<String, dynamic> data}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).collection('pdfs').doc(pdfId).update(data);
    } catch (e) {
      print("Error updating PDF: $e");
      throw Exception('Failed to update PDF.');
    }
  }
  ///Upadate Question
  Future<void> updateQuestion({required String courseId, required String subjectId, required String chapterId, required QuestionModel question}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).collection('questions').doc(question.id).update(question.toFirestore());
    } catch (e) {
      print("Error updating question: $e");
      throw Exception('Failed to update question.');
    }
  }

  // --- DELETE OPERATIONS ---
  /// Deletes a course document.
  /// IMPORTANT: This does NOT delete the sub-collections (subjects, chapters, etc.).
  /// For a full recursive delete, you must use a Firebase Cloud Function.
  Future<void> deleteCourse({required String courseId}) async {
    try {
      await _coursesRef().doc(courseId).delete();
    } catch (e) {
      print("Error deleting course: $e");
      throw Exception('Failed to delete course.');
    }
  }
  /// Deletes a specific video.
  Future<void> deleteVideo({required String courseId, required String subjectId, required String chapterId, required String videoId}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).collection('videos').doc(videoId).delete();
    } catch (e) {
      print("Error deleting video: $e");
      throw Exception('Failed to delete video.');
    }
  }

  /// Deletes a specific PDF.
  Future<void> deletePdf({required String courseId, required String subjectId, required String chapterId, required String pdfId}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).collection('pdfs').doc(pdfId).delete();
    } catch (e) {
      print("Error deleting PDF: $e");
      throw Exception('Failed to delete PDF.');
    }
  }

  /// Deletes a chapter. IMPORTANT: This does NOT delete sub-collections (videos, pdfs).
  /// For a full cleanup, you need to delete sub-collections first or use a Cloud Function.
  Future<void> deleteChapter({required String courseId, required String subjectId, required String chapterId}) async {
    try {
      // You would first need to fetch and delete all videos and PDFs inside this chapter.
      // This is left as an exercise. For now, it only deletes the chapter document itself.
      await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).delete();
    } catch (e) {
      print("Error deleting chapter: $e");
      throw Exception('Failed to delete chapter.');
    }
  }

  /// Deletes a subject. IMPORTANT: This does NOT delete the 'chapters' sub-collection.
  Future<void> deleteSubject({required String courseId, required String subjectId}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).delete();
    } catch (e) {
      print("Error deleting subject: $e");
      throw Exception('Failed to delete subject.');
    }
  }
  /// Deletes a question
  Future<void> deleteQuestion({required String courseId, required String subjectId, required String chapterId, required String questionId}) async {
    try {
      await _coursesRef().doc(courseId).collection('subjects').doc(subjectId).collection('chapters').doc(chapterId).collection('questions').doc(questionId).delete();
    } catch (e) {
      print("Error deleting question: $e");
      throw Exception('Failed to delete question.');
    }}
  /// Results Management
  /// Submits a test result for a user.
  Future<void>submitResult({required ResultModel result}) async {
    try {
      await _firestore.collection('results').add(result.toFirestore());
    } catch (e) {
      print("Error submitting result: $e");
      throw Exception('Failed to submit result.');
    }
  }
  Future<ResultModel> getPreviousResult({required String userId, required String chapterId}) async {
    try {
      final querySnapshot = await _firestore
          .collection('results')
          .where('userId', isEqualTo: userId)
          .where('chapterId', isEqualTo: chapterId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('No previous results found.');
      }

      return ResultModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      print("Error fetching previous result: $e");
      throw Exception('Failed to fetch previous result.');
    }
  }

}*/
