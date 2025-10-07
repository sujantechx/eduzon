// lib/presentation/screens/public/qr_payment_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/courses_moddel.dart';

/// Responsive QR Payment screen
class QrPaymentScreen extends StatelessWidget {
  final CoursesModel course;

  const QrPaymentScreen({super.key, required this.course});

  String _formattedPrice(num? price) {
    if (price == null) return '0';
    // Simple formatting — you can replace with NumberFormat if intl is available.
    return price.toString();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isLandscape = mq.orientation == Orientation.landscape;
    final screenWidth = mq.size.width;

    // Use a comfortable max width on wide screens so content doesn't stretch too far.
    final maxContentWidth = screenWidth > 900 ? 700.0 : double.infinity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Payment'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Course info row for larger screens (landscape/tablet)
                  if (isLandscape)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: QR and instructions
                        Expanded(child: _buildQrCard(context)),

                        const SizedBox(width: 16),

                        // Right: Course details
                        SizedBox(
                          width: 260,
                          child: _buildCourseCard(context),
                        ),
                      ],
                    )
                  else ...[
                    _buildCourseCard(context),
                    const SizedBox(height: 16),
                    _buildQrCard(context),
                  ],

                  const SizedBox(height: 24),

                  // Button area: keep it pinned to bottom-ish on small screens by adding spacing
                  ElevatedButton(
                    onPressed: () {
                      // When navigating, pass the course id to the register flow
                      context.push(AppRoutes.register, extra: course.id);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('I Have Paid — Continue to Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQrCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Scan to Pay',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Price emphasised
            Text(
              '₹${_formattedPrice(course.price)}',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // QR Image with adaptive sizing and fallback
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360, maxHeight: 360),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildQrImage(),
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'After paying, copy the Transaction ID. You will need to enter it on the next screen.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 72,
              height: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: course.imageUrl != null && course.imageUrl!.isNotEmpty
                    ? Image.network(
                  course.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _placeholderThumbnail(),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(child: CircularProgressIndicator(value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1) : null));
                  },
                )
                    : _placeholderThumbnail(),
              ),
            ),

            const SizedBox(width: 12),

            // Title + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title ?? 'Course',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  // Text(
                  //   'ID: ${course.id ?? '-'}',
                  //   style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderThumbnail() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.school, size: 36, color: Colors.grey)),
    );
  }

  Widget _buildQrImage() {
    // Try to load an asset image but don't crash if missing.
    // Keep the asset path the same as you had; if you prefer svg or network QR, update here.
    try {
      return Image.asset(
        'assets/images/payment_qr.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _qrPlaceholder(),
      );
    } catch (e) {
      return _qrPlaceholder();
    }
  }

  Widget _qrPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('QR not available', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
