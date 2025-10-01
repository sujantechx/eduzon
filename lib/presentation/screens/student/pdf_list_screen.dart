import 'package:eduzon/data/repositories/admin_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/chapter_model.dart';
import '../../../data/models/pdf_model.dart';
import '../../../data/models/subject_model.dart';

class PdfListScreen extends StatelessWidget {
  final SubjectModel subject;
  final ChapterModel chapter;
  final String courseId;
  const PdfListScreen({super.key, required this.subject, required this.chapter, required this.courseId});

  Future<void> _launchURL(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the PDF: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDFs for ${chapter.title}')),
      body: // Replace StreamBuilder with FutureBuilder
      FutureBuilder<List<PdfModel>>(
        future: context.read<AdminRepository>().getPdfs(
          courseId: courseId,
          subjectId: subject.id,
          chapterId: chapter.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No PDFs found for this chapter.'));
          }

          final pdfs = snapshot.data!;
          return ListView.builder(
            itemCount: pdfs.length,
            itemBuilder: (context, index) {
              final pdf = pdfs[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.deepPurple),
                  title: Text(pdf.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    _launchURL(pdf.url, context);
                    Navigator.of(context).pushNamed(AppRoutes.pdfViewer, arguments: pdf.url);
                  },
                ),
              );
            },
          );
        },
      )

    );
  }
}