import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final promotions = [
      {
        'title': 'ลด 20% ค่าบริการ',
        'description': 'สำหรับลูกค้าใหม่ ใช้ได้ทุกบริการ',
        'code': 'WELCOME20',
        'validUntil': '31 ม.ค. 2569',
        'discount': '20%',
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'ฟรีค่าเดินทาง',
        'description': 'เมื่อใช้บริการเปลี่ยนยาง',
        'code': 'FREETIRE',
        'validUntil': '15 ก.พ. 2569',
        'discount': 'ฟรี',
        'color': AppTheme.accentColor,
      },
      {
        'title': 'ลด 100 บาท',
        'description': 'เมื่อใช้บริการครบ 500 บาท',
        'code': 'SAVE100',
        'validUntil': '28 ก.พ. 2569',
        'discount': '฿100',
        'color': AppTheme.warningColor,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('โปรโมชั่น')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: promotions.length,
        itemBuilder: (context, index) {
          final promo = promotions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  (promo['color'] as Color),
                  (promo['color'] as Color).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (promo['color'] as Color).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative circles
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  left: -30,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              promo['discount'] as String,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                          const Icon(Icons.local_offer, color: Colors.white54, size: 30),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        promo['title'] as String,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promo['description'] as String,
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('รหัส', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  promo['code'] as String,
                                  style: TextStyle(
                                    color: promo['color'] as Color,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('หมดอายุ', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                              Text(
                                promo['validUntil'] as String,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
