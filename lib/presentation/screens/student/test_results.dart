// lib/presentation/screens/student/quiz_result_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eduzon/data/models/result_model.dart';
import 'package:eduzon/data/models/question_model.dart';
import 'package:eduzon/logic/test/quiz_cubit.dart';

class QuizResultScreen extends StatelessWidget {
  final ResultModel result;
  final List<QuestionModel> questions;
  final String courseId;
  final String subjectId;
  final String chapterId;

  const QuizResultScreen({
    Key? key,
    required this.result,
    required this.questions,
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            // Answer Review Section
            const Text('Answer Review', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...result.answers.asMap().entries.map((entry) {
              final answer = entry.value;
              final question = questions.firstWhere(
                    (q) => q.id == answer['questionId'],
                orElse: () => throw Exception('Question not found for ID: ${answer['questionId']}'),
              );

              // ✅ CORRECTED: Use a null-safe approach for userAnswer
              final userAnswerIndex = answer['userAnswer'] as int?;
              final isCorrect = userAnswerIndex == answer['correctAnswer'];

              return Card(
                color: isCorrect ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question content (text or image)
                      if (question.type == 'image' && question.imageUrl != null)
                        Image.network(question.imageUrl!),
                      if (question.text != null)
                        Text(question.text!),
                      const SizedBox(height: 8),

                      // User's Answer
                      Text(
                        // ✅ CORRECTED: Provide a default string if userAnswerIndex is null
                        'Your Answer: ${userAnswerIndex != null ? question.options[userAnswerIndex] : 'Not Answered'}',
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
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Pop the current results screen.
                    // context.pop();
                    // Trigger the retest logic in the QuizCubit.
                    context.read<QuizCubit>().retest();
                  },
                  child: const Text('Retake Test'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: ()=> context.pop(), child: Text("Final Submit"))
              ],
            )

          ],
        ),
      ),
    );
  }
}