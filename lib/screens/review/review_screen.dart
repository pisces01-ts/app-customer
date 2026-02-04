import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/service_request_model.dart';
import '../../providers/request_provider.dart';
import '../../config/theme.dart';
import '../home/home_screen.dart';

class ReviewScreen extends StatefulWidget {
  final ServiceRequestModel request;

  const ReviewScreen({super.key, required this.request});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _rating = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);

    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    final success = await requestProvider.submitReview(
      requestId: widget.request.requestId,
      rating: _rating.toInt(),
      comment: _commentController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ขอบคุณสำหรับรีวิว!'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
      }
      _goHome();
    }
  }

  void _goHome() {
    Provider.of<RequestProvider>(context, listen: false).clearCurrentRequest();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ให้คะแนน'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _goHome,
            child: const Text('ข้าม'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: AppTheme.accentColor,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'การซ่อมเสร็จสิ้น!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'กรุณาให้คะแนนช่างที่ให้บริการ',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // Technician info
            if (widget.request.techName != null) ...[
              CircleAvatar(
                radius: 40,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  widget.request.techName![0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.request.techName!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
            ],

            // Rating
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 48,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, _) => const Icon(
                Icons.star_rounded,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() => _rating = rating);
              },
            ),
            const SizedBox(height: 8),
            Text(
              _getRatingText(_rating.toInt()),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // Comment
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'เขียนความคิดเห็น (ไม่บังคับ)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('ส่งรีวิว'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'แย่มาก';
      case 2:
        return 'แย่';
      case 3:
        return 'พอใช้';
      case 4:
        return 'ดี';
      case 5:
        return 'ดีมาก';
      default:
        return '';
    }
  }
}
