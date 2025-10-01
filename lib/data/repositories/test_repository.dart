/*
// lib/data/repositories/test_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduzon/data/models/chapter_model.dart';
import 'package:eduzon/data/models/courses_moddel.dart';
import 'package:eduzon/data/models/subject_model.dart';
import '../models/question_model.dart';
import '../models/result_model.dart';

class TestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Admin-specific methods (CRUD)

  /// Adds a new question to a specific chapter.
  Future<void> addQuestion({
    required String courseId,
    required String subjectId,
    required String chapterId,
    required QuestionModel question,
  }) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .doc(chapterId)
          .collection('questions')
          .add(question.toFirestore());
    } catch (e) {
      throw Exception('Failed to add question: $e');
    }
  }

  /// Updates an existing question.
  Future<void> updateQuestion({
    required String courseId,
    required String subjectId,
    required String chapterId,
    required QuestionModel question,
  }) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .doc(chapterId)
          .collection('questions')
          .doc(question.id)
          .update(question.toFirestore());
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }

  /// Deletes a question.
  Future<void> deleteQuestion({
    required String courseId,
    required String subjectId,
    required String chapterId,
    required String questionId,
  }) async {
    try {
      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('subjects')
          .doc(subjectId)
          .collection('chapters')
          .doc(chapterId)
          .collection('questions')
          .doc(questionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  // User-specific methods (Fetch & Submit)

  /// Fetches all questions for a specific chapter.
  Future<List<QuestionModel>> getQuestions({
    required CoursesModel courseId,
    required SubjectModel subjectId,
    required ChapterModel chapterId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .doc(courseId as String?)
          .collection('subjects')
          .doc(subjectId as String?)
          .collection('chapters')
          .doc(chapterId as String?)
          .collection('questions')
          .get();
      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch questions: $e');
    }
  }

  /// Submits a user's test result.
  Future<void> submitResult({
    required ResultModel result,
  }) async {
    try {
      await _firestore
          .collection('results')
          .add(result.toFirestore());
    } catch (e) {
      throw Exception('Failed to submit result: $e');
    }
  }

  /// Fetches a user's previous test result for a chapter.
  Future<ResultModel?> getPreviousResult({
    required String userId,
    required String chapterId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('results')
          .where('userId', isEqualTo: userId)
          .where('chapterId', isEqualTo: chapterId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return ResultModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch previous result: $e');
    }
  }
}*/
