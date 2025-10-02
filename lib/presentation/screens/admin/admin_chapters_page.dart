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
  final String courseId ;

  const AdminChaptersPage({super.key, required this.subject, required this.courseId});

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
                    final sortedChapters = List<ChapterModel>.from(state.chapters)
                      ..sort((a, b) {
                        // If both have a number, sort numerically
                        if (a.chapterNumber != null && b.chapterNumber != null) {
                          return a.chapterNumber!.compareTo(b.chapterNumber!);
                        }
                        // If 'a' has a number and 'b' doesn't, 'a' comes first
                        else if (a.chapterNumber != null && b.chapterNumber == null) {
                          return -1;
                        }
                        // If 'b' has a number and 'a' doesn't, 'b' comes first
                        else if (a.chapterNumber == null && b.chapterNumber != null) {
                          return 1;
                        }
                        // If neither has a number, sort by title as a fallback
                        else {
                          return a.title.compareTo(b.title);
                        }
                      });
                    return ListView.builder(
                      itemCount: sortedChapters.length,
                      itemBuilder: (context, index) {
                        final chapter = sortedChapters[index];
                        return ListTile(
                          leading: Text(
                            chapter.chapterNumber != null ? '${chapter.chapterNumber}.' : '',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          title: Text(chapter.title),
                          trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showAddEditChapterDialog(context, chapter: chapter),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Question'),
                                        content: const Text('Are you sure you want to delete this Chapter? This will also delete all associated quizzes. PDF & Videos'),
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
                                      // Dispatch Delete event
                                      context.read<ChaptersBloc>().add(DeleteChapter(
                                        courseId: courseId,
                                        subjectId: subject.id,
                                        chapterId: chapter.id,
                                      ));
                                    }
                                  },
                                ),
                                const Icon(Icons.arrow_forward_ios),

                              ],
                            ),
                          onTap: () {
                            // Pass a Map with both pieces of data to the chapters page
                            context.push(AppRoutes.adminContent, extra: {
                              'courseId': courseId,
                              'subject': subject,
                              'chapter': chapter,

                            });
                          },
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
    final numberController = TextEditingController(text: isEditing && chapter.chapterNumber != null ? chapter.chapterNumber.toString() : '');

    final chaptersBloc = context.read<ChaptersBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Chapter' : 'Add Chapter'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Chapter Title'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: 'Chapter Number'),
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
                  final int chapterNumber = int.parse(numberController.text);
                  if (isEditing) {
                    chaptersBloc.add(UpdateChapter(
                      courseId: courseId,
                      subjectId: subject.id,
                      chapterId: chapter.id,
                      newTitle: titleController.text,
                      newChapterNumber: chapterNumber,
                    ));
                  } else {
                    chaptersBloc.add(AddChapter(
                      courseId: courseId,
                      subjectId: subject.id,
                      title: titleController.text,
                      chapterNumber: chapterNumber,
                      // Pass the new number
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