// lib/logic/pdf/pdfs_event.dart

import 'package:equatable/equatable.dart';

abstract class PdfsEvent extends Equatable {
  const PdfsEvent();
  @override
  List<Object> get props => [];
}

class LoadPdfs extends PdfsEvent {
  final String courseId;
  final String subjectId;
  final String chapterId;
  const LoadPdfs({required this.courseId, required this.subjectId, required this.chapterId});
  @override
  List<Object> get props => [courseId, subjectId, chapterId];
}

// Add this event
class AddPdf extends PdfsEvent {
  final String courseId;
  final String subjectId;
  final String chapterId;
  final String title;
  final String url;
  final int pdfNumber; // Add this field

  const AddPdf({
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
    required this.title,
    required this.url,
    required this.pdfNumber,
  });

  @override
  List<Object> get props => [courseId, subjectId, chapterId, title, url, pdfNumber];
}

// Add this event
class UpdatePdf extends PdfsEvent {
  final String courseId;
  final String subjectId;
  final String chapterId;
  final String id; // Document ID of the PDF to update
  final String newTitle;
  final String newUrl;
  final int newPdfNumber; // Add this field

  const UpdatePdf({
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
    required this.id,
    required this.newTitle,
    required this.newUrl,
    required this.newPdfNumber,
  });

  @override
  List<Object> get props => [courseId, subjectId, chapterId, id, newTitle, newUrl, newPdfNumber];
}