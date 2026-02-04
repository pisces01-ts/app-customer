import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/request_provider.dart';
import '../../providers/location_provider.dart';
import '../../config/theme.dart';
import '../tracking/tracking_screen.dart';

class RequestScreen extends StatefulWidget {
  final String? preselectedType;

  const RequestScreen({super.key, this.preselectedType});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  String? _selectedType;
  final _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.preselectedType;
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกประเภทปัญหา'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    if (!locationProvider.hasLocation) {
      final success = await locationProvider.getCurrentLocation();
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(locationProvider.errorMessage),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    final success = await requestProvider.submitRequest(
      problemType: _selectedType!,
      lat: locationProvider.latitude,
      lng: locationProvider.longitude,
      problemDetails: _detailsController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TrackingScreen(request: requestProvider.currentRequest!),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(requestProvider.errorMessage),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = Provider.of<RequestProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('แจ้งซ่อม'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ตำแหน่งของคุณ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          locationProvider.currentAddress.isNotEmpty
                              ? locationProvider.currentAddress
                              : 'กำลังค้นหาตำแหน่ง...',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Problem type
            Text(
              'เลือกประเภทปัญหา',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: requestProvider.repairTypes.map((type) {
                final isSelected = _selectedType == type.name;
                return ChoiceChip(
                  label: Text(type.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? type.name : null;
                    });
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Details
            Text(
              'รายละเอียดเพิ่มเติม (ไม่บังคับ)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _detailsController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'อธิบายปัญหาเพิ่มเติม เช่น รถยี่ห้อ รุ่น สี...',
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send),
                          SizedBox(width: 8),
                          Text('ส่งคำขอ'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
