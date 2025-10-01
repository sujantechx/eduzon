// lib/presentation/screens/student/quiz_result_screen.dart

import 'package:flutter/material.dart';
import 'package:eduzon/data/models/result_model.dart';
import 'package:eduzon/data/models/question_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/test/quiz_cubit.dart'; // Assuming you have access to this model

class QuizResultScreen extends StatelessWidget {
  final ResultModel result;
  // You might need to pass the list of questions here to show the details
  final List<QuestionModel> questions;

  const QuizResultScreen({
    Key? key,
    required this.result,
    required this.questions, // Pass the questions list from QuizLoaded state
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
                // Navigate back to the quiz screen
                // or reload the QuizCubit with new questions
                Navigator.of(context).pop();
                context.read<QuizCubit>().loadQuestions(
                  courseId: result.chapterId, // Use the correct IDs
                  subjectId: '...',
                  chapterId: '...',
                );
              },
              child: const Text('Retake Test'),
            ),
          ],
        ),
      ),
    );
  }
}