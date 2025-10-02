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
            final sortedQuestions = List<QuestionModel>.from(state.questions)
              ..sort((a, b) {
                // If both have a question number, sort numerically
                if (a.questionNumber != null && b.questionNumber != null) {
                  return a.questionNumber!.compareTo(b.questionNumber!);
                }
                // If 'a' has a number and 'b' doesn't, 'a' comes first
                else if (a.questionNumber != null && b.questionNumber == null) {
                  return -1;
                }
                // If 'b' has a number and 'a' doesn't, 'b' comes first
                else if (a.questionNumber == null && b.questionNumber != null) {
                  return 1;
                }
                // If neither has a number, sort by ID as a fallback
                else {
                  return a.id.compareTo(b.id);
                }
              });
            return ListView.builder(
              itemCount: state.questions.length,
              itemBuilder: (context, index) {
                final question = state.questions[index];
                return
                  Stack(
                    children: [
                      // Main container for the question content
                      Container(
                        height: 250,
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1), // Add a background color for the container
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: question.type == 'image'
                              ? (question.imageUrl != null && question.imageUrl!.isNotEmpty
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              question.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 250,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Text('Image not available')),
                            ),
                          )
                              : const Text('Image not available'))
                              : (question.text != null && question.text!.isNotEmpty
                              ? Text(
                            question.text!,
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          )
                              : const Text('No question text')),
                        ),
                      ),

                      // Question number at the top-left
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child:Text(
                            question.questionNumber != null ? 'Q ${question.questionNumber}': 'Q ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        /*  Text(
                            'Q ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),*/
                        ),
                      ),

                      // Correct answer and options count at the bottom-left
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            // color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Option: ${question.options.length} | Ans: ${question.correctAnswerIndex + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              // color: Colors.green,
                            ),
                          ),
                        ),
                      ),

                      // Edit and delete buttons at the top-right
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Card(
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showAddEditQuestionDialog(context, question: question),
                              ),
                            ),
                            Card(
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Question'),
                                      content: const Text('Are you sure you want to delete this question?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    context.read<QuestionCubit>().deleteQuestion(
                                      courseId: widget.courseId,
                                      subjectId: widget.subjectId,
                                      chapterId: widget.chapterId,
                                      questionId: question.id,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
/*
                  ListTile(
                  leading: Text(
                    'Q ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  title: Container(
                    height: 250,
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: question.type == 'image'
                        ? (question.imageUrl != null && question.imageUrl!.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        question.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 250,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Text('Image not available')),
                      ),
                    )
                        : const Center(child: Text('Image not available')))
                        : (question.text != null && question.text!.isNotEmpty
                        ? Center(
                      child: Text(
                        question.text!,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    )
                        : const Center(child: Text('No question text'))),
                  ),
                  subtitle: Text(
                      'Options: ${question.options.length} | Correct: ${question.correctAnswerIndex + 1}'),
                  trailing: SizedBox(
                    width: 80,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Positioned(
                          right: 40,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showAddEditQuestionDialog(context, question: question),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => context.read<QuestionCubit>().deleteQuestion(
                              courseId: widget.courseId,
                              subjectId: widget.subjectId,
                              chapterId: widget.chapterId,
                              questionId: question.id,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
*/
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
    final questionNumberController = TextEditingController(
        text: isEditing ? (question.questionNumber?.toString() ?? '') : '');
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
                    // color: Colors.white,
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
                        TextFormField(
                          controller: questionNumberController,
                          decoration: const InputDecoration(
                              labelText: 'Question Number (optional)',
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v != null && v.trim().isNotEmpty) {
                              final number = int.tryParse(v);
                              if (number == null || number < 0) {
                                return 'Enter a valid non-negative number';
                              }
                            }
                            return null;
                          },
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
                            ElevatedButton(
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
                                  // Collect options from controllers
                                  final int questionNumber = questionNumberController.text.isNotEmpty
                                      ? int.parse(questionNumberController.text)
                                      : 0; // Default to 0 if empty
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
                                      questionNumber:questionNumber ,
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
                                      questionNumber: questionNumber,
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