import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pdf_model.dart';

class PdfRepository {
  final FirebaseFirestore _firestore;

  // ✅ This now points directly to your single course document.
  final DocumentReference _courseDoc;

  PdfRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _courseDoc = FirebaseFirestore.instance
            .collection('courses')
            .doc('ojee_2025_2026_batch'); // 🎯 Hardcoded course ID

  // ✅ This method is now simpler and no longer needs a courseId.
  Stream<List<PdfModel>> getPdf({
    required String subjectId,
    required String chapterId,
  }) {
    return _courseDoc // Use the hardcoded course document reference
        .collection('subjects')
        .doc(subjectId)
        .collection('chapters')
        .doc(chapterId)
        .collection('pdfs')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PdfModel.fromSnapshot(doc)).toList();
    });
  }
}