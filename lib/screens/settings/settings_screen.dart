import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../profile/edit_profile_screen.dart';
import '../notifications/notifications_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่า')),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('บัญชี'),
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'แก้ไขโปรไฟล์',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          ),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'เปลี่ยนรหัสผ่าน',
            onTap: () => _showChangePasswordDialog(),
          ),

          // Notifications Section
          _buildSectionHeader('การแจ้งเตือน'),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
            ),
            title: const Text('การแจ้งเตือน'),
            subtitle: const Text('รับการแจ้งเตือนเมื่อมีอัปเดต'),
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.location_on_outlined, color: AppTheme.accentColor),
            ),
            title: const Text('ตำแหน่งที่ตั้ง'),
            subtitle: const Text('อนุญาตให้เข้าถึงตำแหน่ง'),
            value: _locationEnabled,
            onChanged: (v) => setState(() => _locationEnabled = v),
          ),

          // About Section
          _buildSectionHeader('เกี่ยวกับ'),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'เกี่ยวกับแอป',
            onTap: () => _showAboutDialog(),
          ),
          _buildMenuItem(
            icon: Icons.description_outlined,
            title: 'เงื่อนไขการใช้งาน',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'นโยบายความเป็นส่วนตัว',
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(),
              icon: const Icon(Icons.logout, color: AppTheme.errorColor),
              label: const Text('ออกจากระบบ', style: TextStyle(color: AppTheme.errorColor)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Version
          Center(
            child: Text('เวอร์ชัน 1.0.0', style: TextStyle(color: AppTheme.textMuted)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title, style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เปลี่ยนรหัสผ่าน'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'รหัสผ่านปัจจุบัน'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'รหัสผ่านใหม่'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'ยืนยันรหัสผ่านใหม่'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('เปลี่ยนรหัสผ่านเรียบร้อยแล้ว'), backgroundColor: Colors.green),
              );
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.car_repair, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('CarHelp'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('แอปพลิเคชันบริการช่วยเหลือรถยนต์ฉุกเฉิน 24 ชั่วโมง'),
            SizedBox(height: 12),
            Text('เวอร์ชัน: 1.0.0'),
            Text('พัฒนาโดย: CarHelp Team'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ปิด')),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ออกจากระบบ'),
        content: const Text('คุณต้องการออกจากระบบใช่หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
    );
  }
}
