// lib/data/models/question_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class QuestionModel extends Equatable {
  final String id;
  final String type; // 'text' or 'image'
  final String? text;
  final String? imageUrl;
  final List<String> options;
  final int correctAnswerIndex;

  const QuestionModel({
    required this.id,
    required this.type,
    this.text,
    this.imageUrl,
    required this.options,
    required this.correctAnswerIndex,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) throw Exception("Question data is null.");
    return QuestionModel(
      id: doc.id,
      type: data['type'] ?? 'text', // Default to text
      text: data['text'],
      imageUrl: data['imageUrl'],
      options: List<String>.from(data['options'] ?? []),
      correctAnswerIndex: data['correctAnswerIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      if (type == 'text') 'text': text,
      if (type == 'image') 'imageUrl': imageUrl,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
    };
  }

  @override
  List<Object?> get props => [id, type, text, imageUrl, options, correctAnswerIndex];
}