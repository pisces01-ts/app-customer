import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/service_request_model.dart';
import '../../providers/request_provider.dart';
import '../../config/theme.dart';
import '../review/review_screen.dart';

class TrackingScreen extends StatefulWidget {
  final ServiceRequestModel request;

  const TrackingScreen({super.key, required this.request});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Timer? _refreshTimer;
  late ServiceRequestModel _request;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _refreshStatus();
    });
  }

  Future<void> _refreshStatus() async {
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    await requestProvider.getRequestStatus(_request.requestId);
    
    if (requestProvider.currentRequest != null) {
      setState(() {
        _request = requestProvider.currentRequest!;
      });

      // ถ้างานเสร็จแล้ว ไปหน้ารีวิว
      if (_request.isCompleted && mounted) {
        _refreshTimer?.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ReviewScreen(request: _request),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _cancelRequest() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยกเลิกคำขอ'),
        content: const Text('คุณต้องการยกเลิกคำขอนี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ไม่'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('ยกเลิก'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final requestProvider = Provider.of<RequestProvider>(context, listen: false);
      final success = await requestProvider.cancelRequest(_request.requestId);
      
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _callTechnician() async {
    if (_request.techPhone != null && _request.techPhone!.isNotEmpty) {
      final uri = Uri.parse('tel:${_request.techPhone}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ติดตามสถานะ'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStatus,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Status card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.getStatusColor(_request.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.getStatusColor(_request.status).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.getStatusColor(_request.status),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(_request.status),
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppTheme.getStatusText(_request.status),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.getStatusColor(_request.status),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getStatusDescription(_request.status),
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Problem info
              _InfoCard(
                title: 'ปัญหาที่แจ้ง',
                icon: Icons.build,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _request.problemType,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_request.problemDetails.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _request.problemDetails,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Technician info
              if (_request.hasTechnician) ...[
                _InfoCard(
                  title: 'ช่างที่รับงาน',
                  icon: Icons.person,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          _request.techName?.isNotEmpty == true
                              ? _request.techName![0].toUpperCase()
                              : 'T',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _request.techName ?? 'ช่าง',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_request.vehicleModel ?? ''} ${_request.vehiclePlate ?? ''}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _callTechnician,
                        icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppTheme.accentColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Price (if available)
              if (_request.price > 0) ...[
                _InfoCard(
                  title: 'ค่าบริการ',
                  icon: Icons.payments,
                  child: Text(
                    '฿${_request.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 16),

              // Cancel button
              if (_request.canCancel) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _cancelRequest,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                    ),
                    child: const Text('ยกเลิกคำขอ'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_top;
      case 'accepted':
        return Icons.check_circle;
      case 'traveling':
        return Icons.directions_car;
      case 'working':
        return Icons.build;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'กำลังค้นหาช่างในบริเวณใกล้เคียง\nกรุณารอสักครู่...';
      case 'accepted':
        return 'ช่างรับงานแล้ว กำลังเตรียมตัวออกเดินทาง';
      case 'traveling':
        return 'ช่างกำลังเดินทางมาหาคุณ';
      case 'working':
        return 'ช่างกำลังทำการซ่อม';
      case 'completed':
        return 'การซ่อมเสร็จสิ้น';
      case 'cancelled':
        return 'คำขอถูกยกเลิก';
      default:
        return '';
    }
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.textMuted),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
