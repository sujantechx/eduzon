// lib/presentation/pages/admin/admin_subjects_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart'; // Your GoRouter routes
import '../../../data/models/subject_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../logic/subject/subject_bloc.dart';
import '../../../logic/subject/subject_event.dart';
import '../../../logic/subject/subject_state.dart';


class AdminSubjectsPage extends StatelessWidget {
  final String courseId;

  const AdminSubjectsPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubjectsBloc(context.read<AdminRepository>())
        ..add(LoadSubjects(courseId: courseId)),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Manage Subjects'),
            ),
            body: BlocConsumer<SubjectsBloc, SubjectState>(
              listener: (context, state) {
                if (state is SubjectsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is SubjectsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SubjectsLoaded) {
                  if (state.subjects.isEmpty) {
                    return const Center(child: Text('No subjects found. Add one!'));
                  }
                  final sortedSubjects = List<SubjectModel>.from(state.subjects)
                    ..sort((a, b) {
                      // If both have a number, sort numerically
                      if (a.subjectNumber != null && b.subjectNumber != null) {
                        return a.subjectNumber!.compareTo(b.subjectNumber!);
                      }
                      // If 'a' has a number and 'b' doesn't, 'a' comes first
                      else if (a.subjectNumber != null && b.subjectNumber == null) {
                        return -1;
                      }
                      // If 'b' has a number and 'a' doesn't, 'b' comes first
                      else if (a.subjectNumber == null && b.subjectNumber != null) {
                        return 1;
                      }
                      // If neither has a number, sort by title as a fallback
                      else {
                        return a.title.compareTo(b.title);
                      }
                    });
                  return ListView.builder(
                    itemCount: sortedSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = sortedSubjects[index];
                      return ListTile(
                        leading: Container(
                          width: 60,
                          child: Row(
                            children: [
                              Text(
                                subject.subjectNumber != null ? '${subject.subjectNumber}.' : '0',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Icon(Icons.topic, color: Colors.blue),
                            ],
                          ),
                        ),

                        title: Text(subject.title),
                        subtitle: Text(subject.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddEditSubjectDialog(context, subject: subject),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Subject'),
                                    content: const Text('Are you sure you want to delete this Subject? This will also delete all associated chapters and quizzes.'),
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
                                  context.read<SubjectsBloc>().add(DeleteSubject(
                                    courseId: courseId,
                                    subjectId: subject.id,
                                  ));
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          context.push(AppRoutes.AdminChapters, extra: {
                            'courseId': courseId,
                            'subject': subject,
                          });
                        },
                      );
                    },
                  );
                }
                return const Center(child: Text('Please wait...'));
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _showAddEditSubjectDialog(context);
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  /// Shows a dialog for either Adding a new subject or Editing an existing one.
  void _showAddEditSubjectDialog(BuildContext context, {SubjectModel? subject}) {
    final isEditing = subject != null;
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: isEditing ? subject.title : '');
    final descriptionController = TextEditingController(text: isEditing ? subject.description : '');
    final numberController = TextEditingController(
      text: isEditing ? subject.subjectNumber.toString() : '',
    );

    final subjectsBloc = context.read<SubjectsBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: 'Subject Number'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a number';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final int subjectNumber = int.parse(numberController.text);
                  if (isEditing) {
                    subjectsBloc.add(UpdateSubject(
                      courseId: courseId,
                      subjectId: subject.id,
                      newTitle: titleController.text,
                      newDescription: descriptionController.text,
                      newSubjectNumber: subjectNumber,
                    ));
                  } else {
                    subjectsBloc.add(AddSubject(
                      courseId: courseId,
                      title: titleController.text,
                      description: descriptionController.text,
                      subjectNumber: subjectNumber,
                    ));
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }
}