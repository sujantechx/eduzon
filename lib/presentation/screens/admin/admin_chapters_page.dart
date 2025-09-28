// lib/presentation/pages/admin/admin_chapters_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../logic/chapter/chapters_bloc.dart';
import '../../../logic/chapter/chapters_event.dart';
import '../../../logic/chapter/chapters_state.dart';

class AdminChaptersPage extends StatelessWidget {
  final SubjectModel subject;
  final String courseId = 'ojee_2025_2026_batch';

  const AdminChaptersPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChaptersBloc(AdminRepository())
        ..add(LoadChapters(courseId: courseId, subjectId: subject.id)),
      // Use a Builder to get a context that is a descendant of the BlocProvider
      child: Builder(
          builder: (context) { // This context can now find the ChaptersBloc
            return Scaffold(
              appBar: AppBar(
                title: Text(subject.title),
              ),
              body: BlocConsumer<ChaptersBloc, ChaptersState>(
                listener: (context, state) {
                  if (state is ChaptersError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${state.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ChaptersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ChaptersLoaded) {
                    if (state.chapters.isEmpty) {
                      return const Center(child: Text('No chapters found. Add one!'));
                    }
                    return ListView.builder(
                      itemCount: state.chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = state.chapters[index];
                        return ListTile(
                            title: Text(chapter.title),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showAddEditChapterDialog(context, chapter: chapter),
                                ),
                                const Icon(Icons.arrow_forward_ios),
                              ],
                            ),
                            onTap: () {
                              context.push(
                                AppRoutes.adminContent,
                                extra: {
                                  'subject': subject,
                                  'chapter': chapter,
                                },
                              );
                            }
                        );
                      },
                    );
                  }
                  if (state is ChaptersError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const Center(child: Text('Loading chapters...'));
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // Call the dialog to add a new chapter
                  _showAddEditChapterDialog(context);
                },
                child: const Icon(Icons.add),
              ),
            );
          }
      ),
    );
  }

  /// Shows a dialog for either Adding a new chapter or Editing an existing one.
  void _showAddEditChapterDialog(BuildContext context, {ChapterModel? chapter}) {
    final isEditing = chapter != null;
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: isEditing ? chapter.title : '');
    // Read the BLoC from the context passed to this method.
    final chaptersBloc = context.read<ChaptersBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Chapter' : 'Add Chapter'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Chapter Title'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
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
                    chaptersBloc.add(UpdateChapter(
                      courseId: courseId,
                      subjectId: subject.id,
                      chapterId: chapter.id,
                      newTitle: titleController.text,
                    ));
                  } else {
                    // Dispatch Add event
                    chaptersBloc.add(AddChapter(
                      courseId: courseId,
                      subjectId: subject.id,
                      title: titleController.text,
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