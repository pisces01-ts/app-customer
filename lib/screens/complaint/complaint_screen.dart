import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ComplaintScreen extends StatefulWidget {
  final int? requestId;
  
  const ComplaintScreen({super.key, this.requestId});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'service';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _complaintTypes = [
    {'value': 'service', 'label': 'คุณภาพบริการ', 'icon': Icons.build},
    {'value': 'technician', 'label': 'พฤติกรรมช่าง', 'icon': Icons.person},
    {'value': 'price', 'label': 'ราคาไม่เหมาะสม', 'icon': Icons.attach_money},
    {'value': 'delay', 'label': 'ล่าช้า', 'icon': Icons.schedule},
    {'value': 'other', 'label': 'อื่นๆ', 'icon': Icons.more_horiz},
  ];

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Call API to submit complaint
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          title: const Text('ส่งเรื่องร้องเรียนแล้ว'),
          content: const Text('ทีมงานจะติดต่อกลับภายใน 24 ชั่วโมง'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('ตกลง'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ร้องเรียน')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.support_agent, color: AppTheme.warningColor, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('แจ้งปัญหาหรือร้องเรียน', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('เราพร้อมรับฟังและแก้ไขปัญหาให้คุณ', style: TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Complaint Type
              const Text('ประเภทปัญหา', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _complaintTypes.map((type) {
                  final isSelected = _selectedType == type['value'];
                  return ChoiceChip(
                    avatar: Icon(type['icon'], size: 18, color: isSelected ? Colors.white : AppTheme.textSecondary),
                    label: Text(type['label']),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = type['value']);
                    },
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textPrimary),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Subject
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'หัวข้อ',
                  hintText: 'สรุปปัญหาสั้นๆ',
                  prefixIcon: Icon(Icons.subject),
                ),
                validator: (v) => v!.isEmpty ? 'กรุณากรอกหัวข้อ' : null,
              ),
              const SizedBox(height: 16),

              // Message
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'รายละเอียด',
                  hintText: 'อธิบายปัญหาของคุณ...',
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (v) => v!.isEmpty ? 'กรุณากรอกรายละเอียด' : null,
              ),
              const SizedBox(height: 24),

              // Job Reference
              if (widget.requestId != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: AppTheme.textMuted),
                      const SizedBox(width: 8),
                      Text('อ้างอิงงาน #${widget.requestId.toString().padLeft(5, '0')}'),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitComplaint,
                  icon: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send),
                  label: Text(_isLoading ? 'กำลังส่ง...' : 'ส่งเรื่องร้องเรียน'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
