/*
import 'dart:developer' as developer;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<void> _pickAndUploadPdf() async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && _selectedChapterId != null) {
      String url = await _storageService.uploadPdf(
        File(result.files.single.path!),
        widget.subject.id,
        _selectedChapterId!,
      );
      _urlController.text = url;
    }
  } catch (e) {
    developer.log('PDF upload error: $e', name: 'UploadPdfScreen');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to upload PDF: $e')),
    );
  }
}

Future<void> _downloadAndPreparePdf() async {
  try {
    final response = await http.get(Uri.parse(widget.url));
    developer.log('Downloading PDF from ${widget.url}', name: 'PdfViewerScreen');
    if (response.statusCode != 200) {
      throw Exception('Failed to download PDF: HTTP ${response.statusCode}');
    }
    final tempDir = await getTemporaryDirectory();
    final fileName = widget.url.split('/').last;
    final file = File('${tempDir.path}/$fileName');
    developer.log('Saving PDF to ${file.path}', name: 'PdfViewerScreen');
    await file.writeAsBytes(response.bodyBytes);
    setState(() {
      _localPath = file.path;
      _isLoading = false;
    });
  } catch (e) {
    developer.log('Error downloading PDF: $e', name: 'PdfViewerScreen');
    setState(() {
      _errorMessage = 'Failed to load PDF: $e';
      _isLoading = false;
    });
  }
}*/
