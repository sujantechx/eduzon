// lib/presentation/screens/student/quiz_result_screen.dart

import 'package:flutter/material.dart';
import 'package:eduzon/data/models/result_model.dart';
import 'package:eduzon/data/models/question_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/test/quiz_cubit.dart'; // Assuming you have access to this model

class QuizResultScreen extends StatelessWidget {
  final ResultModel result;
  final List<QuestionModel> questions;
  final String courseId; // Add this
  final String subjectId; // Add this
  final String chapterId; // Add this

  const QuizResultScreen({
    Key? key,
    required this.result,
    required this.questions,
    required this.courseId, // Make it required
    required this.subjectId, // Make it required
    required this.chapterId, // Make it required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     /* appBar: AppBar(
        title: const Text('Quiz Results'),
      ),*/
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score Summary
            Card(
              color: Colors.green.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text('Your Score', style: TextStyle(fontSize: 20)),
                    Text(
                      '${result.correctAnswers} / ${result.totalQuestions}',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Review Answers Section
            const Text('Answer Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...result.answers.asMap().entries.map((entry) {
              final index = entry.key;
              final answer = entry.value;
              final question = questions.firstWhere((q) => q.id == answer['questionId']);

              final isCorrect = answer['userAnswer'] == answer['correctAnswer'];

              return Card(
                color: isCorrect ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question
                      question.type == 'image'
                          ? Image.network(question.imageUrl!)
                          : Text(question.text!),
                      const SizedBox(height: 8),
                      // User's Answer
                      Text(
                        'Your Answer: ${question.options[answer['userAnswer']] ?? 'Not Answered'}',
                        style: TextStyle(color: isCorrect ? Colors.green : Colors.red),
                      ),
                      // Correct Answer
                      Text(
                        'Correct Answer: ${question.options[answer['correctAnswer']]}',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            // Retake Test Button
             ElevatedButton(
            onPressed: () {
            // Pop the current results screen to go back to the chapter list.
               Navigator.of(context).pop();
            // Trigger the retest logic in the QuizCubit with the necessary IDs.
            context.read<QuizCubit>().retest(
            courseId: courseId,
            subjectId: subjectId,
            chapterId: chapterId,
            );
            },
            child: const Text('Retake Test'),
            )

          ],
        ),
      ),
    );
  }
}