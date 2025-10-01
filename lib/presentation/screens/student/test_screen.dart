// lib/presentation/screens/student/quiz_screen.dart

import 'package:eduzon/data/models/chapter_model.dart';
import 'package:eduzon/data/models/question_model.dart';
import 'package:eduzon/presentation/screens/student/test_results.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/test/quiz_cubit.dart';
import '../../../logic/test/test_state.dart';

class TestScreen extends StatelessWidget {
  final String courseId;
  final String subjectId;
  final ChapterModel chapterId;

  const TestScreen({
    Key? key,
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Load questions when the screen is first built
    context.read<QuizCubit>().loadQuestions(
      courseId: courseId,
      subjectId: subjectId,
      chapterId: chapterId.id,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: BlocBuilder<QuizCubit, QuizState>(
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is QuizError) {
            return Center(child: Text(state.message));
          }
          if (state is QuizLoaded) {
            return _buildQuestionScreen(context, state);
          }
          if (state is QuizCompleted) {
            return _buildResultScreen(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildQuestionScreen(BuildContext context, QuizLoaded state) {
    final question = state.questions[state.currentQuestionIndex];
    final selectedAnswer = state.userAnswers[question.id];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question Header with Progress and Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question ${state.currentQuestionIndex + 1}/${state.questions.length}'),
              Text('Time: ${state.timeLeft}s'),
            ],
          ),
          const SizedBox(height: 16),
          // Question Content (Text or Image)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: question.type == 'image'
                  ? (question.imageUrl != null && question.imageUrl!.isNotEmpty
                  ? Image.network(
                question.imageUrl!,
                errorBuilder: (context, error, stackTrace) =>
                const Text('Image not available'),
              )
                  : const Text('No image provided'))
                  : (question.text != null && question.text!.isNotEmpty
                  ? Text(question.text!)
                  : const Text('No question text')),
            ),
          ),
          const SizedBox(height: 16),
          // Options List
          ...List.generate(question.options.length, (index) {
            return OptionCard(
              optionText: question.options[index],
              isSelected: selectedAnswer == index,
              onTap: () {
                context.read<QuizCubit>().selectAnswer(index);
              },
            );
          }),
          const Spacer(),
          // Submit/Next Button
          ElevatedButton(
            onPressed: () {
              context.read<QuizCubit>().nextQuestion();
            },
            child: Text(state.currentQuestionIndex == state.questions.length - 1
                ? 'Submit Quiz'
                : 'Next'),
          ),
        ],
      ),
    );
  }
  Widget _buildResultScreen(BuildContext context, QuizCompleted state) {
    final result = state.result;
    final questions = state.questions; // ✅ Correctly access questions from the state
    return QuizResultScreen(result: result, questions: questions);
  }
}

// Reusable Option Card Widget
class OptionCard extends StatelessWidget {
  final String optionText;
  final bool isSelected;
  final VoidCallback onTap;

  const OptionCard({
    Key? key,
    required this.optionText,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.blue.withOpacity(0.2) : null,
      child: ListTile(
        title: Text(optionText),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
        onTap: onTap,
      ),
    );
  }
}