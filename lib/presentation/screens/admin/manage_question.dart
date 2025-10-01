// lib/presentation/screens/admin/manage_questions_screen.dart
import 'package:eduzon/logic/test/question_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/question_model.dart';
import '../../../logic/test/question_state.dart';

class ManageQuestion extends StatefulWidget {
  final String courseId;
  final String subjectId;
  final String chapterId;

  const ManageQuestion({
    super.key,
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
  });

  @override
  State<ManageQuestion> createState() => _ManageQuestionState();
}

class _ManageQuestionState extends State<ManageQuestion> {
  @override
  Widget build(BuildContext context) {
    // Dispatch the fetch event as soon as the screen is built
    context.read<QuestionCubit>().fetchQuestions(
      courseId: widget.courseId,
      subjectId: widget.subjectId,
      chapterId: widget.chapterId,
    );

    return Scaffold(
      // appBar: AppBar(title: const Text('Manage Questions')),
      body: BlocConsumer<QuestionCubit, QuestionState>(
        listener: (context, state) {
          if (state is QuestionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is QuestionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is QuestionsLoaded) {
            if (state.questions.isEmpty) {
              return const Center(child: Text('No questions found. Add one!'));
            }
            return ListView.builder(
              itemCount: state.questions.length,
              itemBuilder: (context, index) {
                final question = state.questions[index];
                return ListTile(
                  title: Text(question.text ?? 'No Text'),
                  subtitle: Text('Options: ${question.options.length} | Correct: ${question.correctAnswerIndex + 1}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddEditQuestionDialog(context, question: question),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => context.read<QuestionCubit>().deleteQuestion(
                          courseId: widget.courseId,
                          subjectId: widget.subjectId,
                          chapterId: widget.chapterId,
                          questionId: question.id,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditQuestionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

// lib/presentation/screens/admin/manage_questions_screen.dart

// Note: You must update your QuestionCubit to accept the new parameters for adding/updating questions.
// For example:
// Future<void> addQuestion({required String courseId, required String subjectId, required String chapterId, String? text, String? imageUrl, required List<String> options, required int correctAnswerIndex}) async { ... }
// Future<void> updateQuestion({required String courseId, required String subjectId, required String chapterId, required String id, String? newText, String? newImageUrl, required List<String> newOptions, required int newCorrectAnswerIndex}) async { ... }

// Your _showAddEditQuestionDialog method
  void _showAddEditQuestionDialog(BuildContext context, {QuestionModel? question}) {
    final isEditing = question != null;
    final formKey = GlobalKey<FormState>();

    // ✅ Initialize _questionType based on the existing question
    String _questionType = isEditing ? question.type : 'text';

    final textController = TextEditingController(
        text: isEditing ? question.text : '');
    final imageUrlController = TextEditingController(
        text: isEditing ? question.imageUrl : '');

    final optionsControllers = isEditing
        ? question.options
        .map((opt) => TextEditingController(text: opt))
        .toList()
        : List.generate(4, (_) => TextEditingController());
    final correctAnswerController = TextEditingController(
        text: isEditing ? question.correctAnswerIndex.toString() : '');
    final questionCubit = context.read<QuestionCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (dialogContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery
                .of(dialogContext)
                .viewInsets
                .bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  padding: const EdgeInsets.only(
                      bottom: 30.0, top: 16.0, left: 16.0, right: 16.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            isEditing ? 'Edit Question' : 'Add Question',
                            style: Theme
                                .of(context)
                                .textTheme
                                .headlineSmall,
                          ),
                        ),
                        StatefulBuilder(
                          builder: (context, setModalState) =>
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('Question Type:'),
                                      Radio<String>(
                                        value: 'text',
                                        groupValue: _questionType,
                                        onChanged: (value) {
                                          setModalState(() =>
                                          _questionType = value!);
                                          // Reset the other controller's text
                                          if (value == 'text') {
                                            imageUrlController.clear();
                                          }
                                        },
                                      ),
                                      const Text('Text'),
                                      Radio<String>(
                                        value: 'image',
                                        groupValue: _questionType,
                                        onChanged: (value) {
                                          setModalState(() =>
                                          _questionType = value!);
                                          // Reset the other controller's text
                                          if (value == 'image') {
                                            textController.clear();
                                          }
                                        },
                                      ),
                                      const Text('Image'),
                                    ],
                                  ),
                                  if (_questionType == 'text')
                                    TextFormField(
                                      controller: textController,
                                      decoration: const InputDecoration(
                                          labelText: 'Question Text',
                                          border: OutlineInputBorder()),
                                      validator: (v) =>
                                      v!.trim().isEmpty
                                          ? 'Text is required'
                                          : null,
                                    ),
                                  if (_questionType == 'image')
                                    TextFormField(
                                      controller: imageUrlController,
                                      decoration: const InputDecoration(
                                          labelText: 'Image URL',
                                          border: OutlineInputBorder()),
                                      validator: (v) =>
                                      v!.trim().isEmpty
                                          ? 'Image URL is required'
                                          : null,
                                    ),
                                ],
                              ),
                        ),

                        const SizedBox(height: 16),
                        ...List.generate(4, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TextFormField(
                              controller: optionsControllers[index],
                              decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}',
                                  border: const OutlineInputBorder()),
                              validator: (v) =>
                              v!.trim().isEmpty
                                  ? 'Option is required'
                                  : null,
                            ),
                          );
                        }),
                        TextFormField(
                          controller: correctAnswerController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Correct Option Index (0-3)',
                              border: OutlineInputBorder()),
                          validator: (v) {
                            if (v!.isEmpty) return 'Correct index is required';
                            final index = int.tryParse(v);
                            if (index == null || index < 0 || index > 3)
                              return 'Invalid index';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  final options = optionsControllers.map((
                                      c) => c.text).toList();
                                  final correctIndex = int.parse(
                                      correctAnswerController.text);

                                  if (isEditing) {
                                    questionCubit.updateQuestion(
                                      courseId: widget.courseId,
                                      subjectId: widget.subjectId,
                                      chapterId: widget.chapterId,
                                      id: question.id,
                                      newText: _questionType == 'text'
                                          ? textController.text
                                          : null,
                                      // ✅ Pass imageUrl if type is image
                                      newImageUrl: _questionType == 'image'
                                          ? imageUrlController.text
                                          : null,
                                      newOptions: options,
                                      newCorrectAnswerIndex: correctIndex,
                                      type: '',
                                    );
                                  } else {
                                    questionCubit.addQuestion(
                                      courseId: widget.courseId,
                                      subjectId: widget.subjectId,
                                      chapterId: widget.chapterId,
                                      type: _questionType,
                                      // ✅ Pass the question type
                                      text: _questionType == 'text'
                                          ? textController.text
                                          : null,
                                      imageUrl: _questionType == 'image'
                                          ? imageUrlController.text
                                          : null,
                                      options: options,
                                      correctAnswerIndex: correctIndex,
                                    );
                                  }
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                              child: Text(isEditing ? 'Save' : 'Add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}