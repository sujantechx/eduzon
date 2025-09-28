import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

// Service for uploading files to Firebase Storage
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a PDF file to Firebase Storage and return the download URL
  Future<String> uploadPdf(File file, String subjectId, String chapterId) async {
    try {
      final ref = _storage
          .ref()
          .child('subjects/$subjectId/chapters/$chapterId/pdfs/${file.path.split('/').last}');
      final uploadTask = await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload PDF: $e');
    }
  }
}