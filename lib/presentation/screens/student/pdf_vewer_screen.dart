import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Import for PDFView widget
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Screen to display a PDF from a given URL
class PdfViewerScreen extends StatefulWidget {
  final String url; // URL of the PDF to display

  const PdfViewerScreen({super.key, required this.url});

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _localPath; // Local path of the downloaded PDF
  bool _isLoading = true; // Track loading state
  String? _errorMessage; // Store error message if download or rendering fails

  @override
  void initState() {
    super.initState();
    // Download the PDF when the screen initializes
    _downloadAndPreparePdf();
  }

  // Download the PDF from the URL and save it to a temporary local file
  Future<void> _downloadAndPreparePdf() async {
    try {
      // Fetch the PDF from the provided URL
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF: HTTP ${response.statusCode}');
      }

      // Save the PDF to a temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName = widget.url.split('/').last;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes); // Write the downloaded bytes to the file

      // Update state with the local file path
      setState(() {
        _localPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      // Handle errors during download or file saving
      setState(() {
        _errorMessage = 'Failed to load PDF: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Retry downloading the PDF
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _downloadAndPreparePdf();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _localPath != null
          ? PDFView(
        filePath: _localPath!, // Render the PDF from the local file
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onError: (error) {
          // Handle PDF rendering errors
          setState(() {
            _errorMessage = 'Failed to render PDF: $error';
          });
        },
        onRender: (pages) {
          // Log successful rendering
          debugPrint('PDF rendered with $pages pages');
        },
      )
          : const Center(child: Text('No PDF available')),
    );
  }
}