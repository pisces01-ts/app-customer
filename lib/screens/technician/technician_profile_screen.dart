import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';

class TechnicianProfileScreen extends StatefulWidget {
  final int technicianId;
  final int? requestId;

  const TechnicianProfileScreen({
    super.key,
    required this.technicianId,
    this.requestId,
  });

  @override
  State<TechnicianProfileScreen> createState() => _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _technician;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final response = await _api.get(
      '${ApiConfig.getTechnicianProfile}?technician_id=${widget.technicianId}',
    );

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _technician = response.data!['technician'];
        _reviews = List<Map<String, dynamic>>.from(_technician?['reviews'] ?? []);
      }
    });
  }

  Future<void> _selectTechnician() async {
    if (widget.requestId == null) return;

    setState(() => _isSelecting = true);

    final response = await _api.post(ApiConfig.selectTechnician, body: {
      'request_id': widget.requestId,
      'technician_id': widget.technicianId,
    });

    setState(() => _isSelecting = false);

    if (response.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เลือกช่างสำเร็จ กรุณารอช่างตอบรับ'), backgroundColor: Colors.green),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์ช่าง')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _technician == null
              ? const Center(child: Text('ไม่พบข้อมูลช่าง'))
              : _buildProfile(),
      bottomNavigationBar: widget.requestId != null && _technician != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _isSelecting ? null : _selectTechnician,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: _isSelecting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('เลือกช่างคนนี้'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildProfile() {
    final rating = double.tryParse(_technician!['avg_rating']?.toString() ?? '0') ?? 0;
    final totalJobs = int.tryParse(_technician!['total_jobs']?.toString() ?? '0') ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 50, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 16),
                Text(
                  _technician!['fullname'] ?? 'ไม่ระบุชื่อ',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('${rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(' ($totalJobs รีวิว)', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Info cards
          _buildInfoCard('รถ', '${_technician!['vehicle_model'] ?? ''} ${_technician!['vehicle_plate'] ?? ''}', Icons.directions_car),
          _buildInfoCard('ความเชี่ยวชาญ', _technician!['expertise'] ?? 'ช่างทั่วไป', Icons.build),
          _buildInfoCard('เบอร์โทร', _technician!['phone'] ?? '-', Icons.phone),

          const SizedBox(height: 24),

          // Reviews
          const Text('รีวิวจากลูกค้า', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          if (_reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text('ยังไม่มีรีวิว', style: TextStyle(color: Colors.grey[500])),
              ),
            )
          else
            ..._reviews.map((review) => _buildReviewCard(review)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = int.tryParse(review['rating']?.toString() ?? '0') ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(review['customer_name'] ?? 'ลูกค้า', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                ...List.generate(5, (i) => Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  size: 16,
                  color: Colors.amber,
                )),
              ],
            ),
            if (review['comment'] != null && review['comment'].toString().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(review['comment']),
            ],
            const SizedBox(height: 4),
            Text(
              review['created_at'] ?? '',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
