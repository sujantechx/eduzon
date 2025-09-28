// lib/presentation/pages/admin/admin_subjects_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart'; // Your GoRouter routes
import '../../../data/models/subject_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../logic/admin/subject_bloc.dart';
import '../../../logic/admin/subject_event.dart';
import '../../../logic/admin/subject_state.dart';


class AdminSubjectsPage extends StatelessWidget {
  // You would likely get this from a previous screen or a global state
  final String courseId = 'ojee_2025_2026_batch';

  const AdminSubjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubjectsBloc(AdminRepository())
        ..add(LoadSubjects(courseId: courseId)),
      // Use a Builder to get a context that is a descendant of the BlocProvider

      child: Builder(
          builder: (context) { // <-- This 'context' can now find the SubjectsBloc
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
                    return ListView.builder(
                      itemCount: state.subjects.length,
                      itemBuilder: (context, index) {
                        final subject = state.subjects[index];
                        return ListTile(
                          title: Text(subject.title),
                          subtitle: Text(subject.description),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            // Now this context is correct
                            onPressed: () => _showAddEditSubjectDialog(context, subject: subject),
                          ),
                          onTap: () {
                            context.push(AppRoutes.AdminChapters, extra: subject);
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
                  // And this context is also correct
                  _showAddEditSubjectDialog(context);
                },
                child: const Icon(Icons.add),
              ),
            );
          }
      ),
    );
  }

  /// Shows a dialog for either Adding a new subject or Editing an existing one.
  void _showAddEditSubjectDialog(BuildContext context, {SubjectModel? subject}) {
    final isEditing = subject != null;
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: isEditing ? subject.title : '');
    final descriptionController = TextEditingController(text: isEditing ? subject.description : '');
    // Read the BLoC once, as it won't change while the dialog is open.
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
                  if (isEditing) {
                    // Dispatch Update event
                    subjectsBloc.add(UpdateSubject(
                      courseId: courseId,
                      subjectId: subject.id,
                      newTitle: titleController.text,
                      newDescription: descriptionController.text,
                    ));
                  } else {
                    // Dispatch Add event
                    subjectsBloc.add(AddSubject(
                      courseId: courseId,
                      title: titleController.text,
                      description: descriptionController.text,
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