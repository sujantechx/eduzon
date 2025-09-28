// lib/presentation/screens/dashboard/pdf_viewer_screen.dart

import 'package:eduzon/presentation/widgets/watermark_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../data/models/pdf_model.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_state.dart';

class PdfViewerScreen extends StatefulWidget {
  final PdfModel pdfModel;
  const PdfViewerScreen({super.key, required this.pdfModel});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  // ✅ Controller to get document details like page count
  late final PdfViewerController _pdfViewerController;
  int _pageCount = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pdfModel.title)),
      // ✅ Add a bottom navigation bar to show the page count
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Page: $_currentPage / $_pageCount',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.pdfModel.url,
            controller: _pdfViewerController,
            // ✅ Callback to know when the document is loaded
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                _pageCount = details.document.pages.count;
              });
            },
            // ✅ Callback to update the current page number
            onPageChanged: (PdfPageChangedDetails details) {
              setState(() {
                _currentPage = details.newPageNumber;
              });
            },
            onDocumentLoadFailed: (details) {
              debugPrint("PDF Load Failed: ${details.error} - ${details.description}");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to load PDF: ${details.description}")),
              );
            },
          ),
          // Your watermark remains unchanged
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return WatermarkWidget(text: state.userModel.email);
              }
              return const SizedBox.shrink();
            },
          ),
          // ✅ Add a loading indicator that shows on top while the PDF is loading
          // The viewer's initial state is a loading indicator.
          if (_pageCount == 0)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}