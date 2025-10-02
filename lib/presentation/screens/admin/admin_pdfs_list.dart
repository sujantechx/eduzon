// lib/presentation/pages/admin/admin_pdfs_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/pdf_model.dart';
import '../../../logic/pdf/pdfs_bloc.dart';
import '../../../logic/pdf/pdfs_event.dart';
import '../../../logic/pdf/pdfs_state.dart';

class AdminPdfsList extends StatelessWidget {
  final String courseId;
  final String subjectId;
  final String chapterId;

  const AdminPdfsList({
    super.key,
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
  });


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PdfsBloc, PdfsState>(
        listener: (context, state) {
          if (state is PdfsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is PdfsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PdfsLoaded) {
            if (state.pdfs.isEmpty) {
              return const Center(child: Text('No PDFs found. Add one!'));
            }
            return ListView.builder(
              itemCount: state.pdfs.length,
              itemBuilder: (context, index) {
                final pdf = state.pdfs[index];
                return InkWell(
                  onTap: () {
                    // Navigate to the ADMIN PDF viewer route
                    Navigator.of(context).pushNamed(AppRoutes.adminPdfViewer, arguments: pdf.url);                  },
                  child: ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(pdf.title),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showAddEditPdfDialog(context, pdf: pdf),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditPdfDialog(context),
        heroTag: 'pdfs_fab',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditPdfDialog(BuildContext context, {PdfModel? pdf}) {
    final isEditing = pdf != null;
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: isEditing ? pdf.title : '');
    final urlController = TextEditingController(text: isEditing ? pdf.url : '');
// The first line is correct, assuming 'isEditing' and 'pdf' are defined.
    final pdfNumberController = TextEditingController(text: isEditing && pdf.pdfNumber != null ? pdf.pdfNumber.toString() : '');
// Corrected and safer way to get the integer value.
    final int? pdfNumber = int.tryParse(pdfNumberController.text);

    final pdfsBloc = context.read<PdfsBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit PDF' : 'Add PDF'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: pdfNumberController,
                    decoration: const InputDecoration(labelText: 'PDF Number (optional)'),
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
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) => v!.trim().isEmpty ? 'Title is required' : null,
                  ),
                  TextFormField(
                    controller: urlController,
                    decoration: const InputDecoration(labelText: 'PDF URL'),
                    validator: (v) => v!.trim().isEmpty ? 'URL is required' : null,
                  ),
                ],
              ),
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
                  final int pdfNumbers = int.tryParse(pdfNumberController.text) ?? (isEditing ? pdf!.pdfNumber ?? 0 : 0);
                  if (isEditing) {
                    pdfsBloc.add(UpdatePdf(
                      courseId: courseId,
                      subjectId: subjectId,
                      chapterId: chapterId,
                      id: pdf.id,
                      newTitle: titleController.text,
                      newUrl: urlController.text,
                      newPdfNumber: pdfNumbers, // Keep the same number for existing PDFs
                    ));
                  } else {
                    pdfsBloc.add(AddPdf(
                      courseId: courseId,
                      subjectId: subjectId,
                      chapterId: chapterId,
                      title: titleController.text,
                      url: urlController.text,
                      pdfNumber: pdfNumbers, // Default number for new PDFs
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