import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';
import 'technician_profile_screen.dart';

class TechnicianListScreen extends StatefulWidget {
  final double lat;
  final double lng;
  final int? requestId;

  const TechnicianListScreen({
    super.key,
    required this.lat,
    required this.lng,
    this.requestId,
  });

  @override
  State<TechnicianListScreen> createState() => _TechnicianListScreenState();
}

class _TechnicianListScreenState extends State<TechnicianListScreen> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _technicians = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
  }

  Future<void> _loadTechnicians() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final response = await _api.post(ApiConfig.findNearbyTechnicians, body: {
      'lat': widget.lat,
      'lng': widget.lng,
      'radius': 20,
    });

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _technicians = List<Map<String, dynamic>>.from(response.data!['technicians'] ?? []);
      } else {
        _error = response.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ช่างใกล้เคียง'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTechnicians,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_error, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTechnicians,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    if (_technicians.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('ไม่พบช่างในบริเวณใกล้เคียง', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('กรุณาลองใหม่ภายหลัง', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTechnicians,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _technicians.length,
        itemBuilder: (context, index) {
          final tech = _technicians[index];
          return _buildTechnicianCard(tech);
        },
      ),
    );
  }

  Widget _buildTechnicianCard(Map<String, dynamic> tech) {
    final rating = double.tryParse(tech['avg_rating']?.toString() ?? '0') ?? 0;
    final totalJobs = int.tryParse(tech['total_jobs']?.toString() ?? '0') ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TechnicianProfileScreen(
                technicianId: tech['user_id'],
                requestId: widget.requestId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: const Icon(Icons.person, size: 30, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tech['fullname'] ?? 'ไม่ระบุชื่อ',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${rating.toStringAsFixed(1)} ($totalJobs งาน)'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tech['expertise'] ?? 'ช่างทั่วไป',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tech['distance_text'] ?? '',
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
