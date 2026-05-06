import 'package:flutter/material.dart';
import '../config/constants.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  static const _topics = [
    (
      'storm', 'Phòng chống bão',
      ['Gia cố nhà cửa trước khi bão đến', 'Tích trữ nước uống và thức ăn khô đủ 3-5 ngày',
       'Sạc đầy pin điện thoại và đèn pin', 'Ở trong nhà, tránh xa cửa sổ khi bão đổ bộ',
       'Không ra ngoài khi bão đang xảy ra', 'Sau bão: cẩn thận cây gãy, dây điện đứt']
    ),
    (
      'flood', 'Ứng phó lũ lụt',
      ['Theo dõi mực nước sông hàng ngày mùa mưa', 'Di chuyển đồ vật quan trọng lên tầng cao',
       'Không lội qua dòng nước chảy mạnh', 'Chuẩn bị phao cứu sinh nếu ở vùng trũng',
       'Tắt điện trước khi nước vào nhà', 'Liên hệ ngay UBND xã khi có nguy cơ']
    ),
    (
      'landslide', 'Phòng tránh sạt lở',
      ['Không xây nhà sát chân taluy đường', 'Nhận biết dấu hiệu: vết nứt mới, tiếng đất đá rơi',
       'Tránh đi lại vùng sườn dốc sau mưa lớn', 'Di chuyển khẩn cấp khi thấy dấu hiệu sạt lở',
       'Không quay lại khu vực nguy hiểm', 'Gọi 1800 599 920 để báo cáo']
    ),
    (
      'heatwave', 'Đối phó nắng nóng',
      ['Uống 2-3 lít nước mỗi ngày, tránh rượu bia', 'Không ra ngoài 10h-16h khi nắng gắt',
       'Mặc quần áo sáng màu, thoáng mát', 'Dùng kem chống nắng SPF 30+',
       'Quan tâm người già, trẻ nhỏ', 'Nhận biết say nắng: chóng mặt, buồn nôn → gọi 115']
    ),
    (
      'tree_fall', 'Tránh cây đổ',
      ['Không đứng gần cây cao khi có gió mạnh', 'Không đỗ xe dưới tán cây lớn',
       'Cắt tỉa cành mục trước mùa bão', 'Sau bão: cẩn thận cây ngã chặn đường',
       'Không cưa cây ngã một mình', 'Báo cây nguy hiểm cho chính quyền địa phương']
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiến thức phòng chống thiên tai'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildEmergencyCard(),
          const SizedBox(height: 12),
          ..._topics.map((topic) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TopicCard(topic: topic),
              )),
        ],
      ),
    );
  }

  Widget _buildEmergencyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kColorRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kColorRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.phone_in_talk, color: kColorRed, size: 22),
              SizedBox(width: 8),
              Text('Số điện thoại khẩn cấp',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kColorRed)),
            ],
          ),
          const SizedBox(height: 12),
          _EmergencyContact('Phòng chống thiên tai', kEmergencyNumber, Icons.warning_rounded),
          _EmergencyContact('Công an', kPoliceNumber, Icons.local_police),
          _EmergencyContact('Cứu hỏa', kFireNumber, Icons.local_fire_department),
          _EmergencyContact('Cấp cứu', kMedicalNumber, Icons.local_hospital),
        ],
      ),
    );
  }
}

class _TopicCard extends StatefulWidget {
  final (String, String, List<String>) topic;
  const _TopicCard({required this.topic});

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final (type, title, tips) = widget.topic;
    final color = kDisasterColors[type] ?? kPrimaryColor;
    final icon = kDisasterIcons[type] ?? Icons.info;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey),
                ],
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 1, indent: 14, endIndent: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Column(
                  children: tips.map((tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_outline, size: 16, color: color),
                            const SizedBox(width: 8),
                            Expanded(child: Text(tip, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      )).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmergencyContact extends StatelessWidget {
  final String name;
  final String number;
  final IconData icon;
  const _EmergencyContact(this.name, this.number, this.icon);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
            Text(number,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold, color: kPrimaryColor)),
          ],
        ),
      );
}
