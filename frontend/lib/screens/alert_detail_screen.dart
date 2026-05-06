import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../models/risk_data.dart';
import '../services/notification_service.dart';
import '../widgets/alert_level_badge.dart';
import 'forecast_screen.dart';

class AlertDetailScreen extends StatelessWidget {
  final GridCell cell;

  const AlertDetailScreen({super.key, required this.cell});

  @override
  Widget build(BuildContext context) {
    final dominantType = cell.risks.dominantType;
    final color = kDisasterColors[dominantType] ?? kPrimaryColor;
    final icon = kDisasterIcons[dominantType] ?? Icons.warning_rounded;
    final label = kDisasterLabels[dominantType] ?? dominantType;

    return Scaffold(
      backgroundColor: kSurfaceColor,
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Text('Cảnh báo $label'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(color, icon, label),
            const SizedBox(height: 16),
            _buildLocationCard(),
            const SizedBox(height: 12),
            _buildWeatherCard(),
            const SizedBox(height: 12),
            _buildRisksCard(),
            const SizedBox(height: 12),
            _buildActionCard(context, dominantType),
            const SizedBox(height: 12),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color, IconData icon, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 12),
          Text(label.toUpperCase(),
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          AlertLevelBadge(level: cell.alertLevel, large: true),
          const SizedBox(height: 8),
          Text(
            'Mức nguy cơ: ${(cell.risks.maxRisk * 100).toStringAsFixed(0)}%',
            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.location_on, title: 'Vị trí'),
          const SizedBox(height: 8),
          Text('${cell.district}, Tỉnh Phú Thọ',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(cell.commune, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text('Tọa độ: ${cell.centerLat.toStringAsFixed(4)}°N, ${cell.centerLng.toStringAsFixed(4)}°E',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.cloud, title: 'Thời tiết hiện tại'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16, runSpacing: 8,
            children: [
              _WeatherItem(Icons.thermostat, '${cell.temperature.toStringAsFixed(1)}°C', 'Nhiệt độ'),
              _WeatherItem(Icons.water_drop, '${cell.rain24h.toStringAsFixed(1)} mm', 'Mưa 24h'),
              _WeatherItem(Icons.air, '${cell.windSpeed.toStringAsFixed(0)} km/h', 'Gió'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRisksCard() {
    final riskItems = [
      ('Bão', cell.risks.storm, kDisasterColors['storm']!),
      ('Lũ lụt', cell.risks.flood, kDisasterColors['flood']!),
      ('Sạt lở', cell.risks.landslide, kDisasterColors['landslide']!),
      ('Cây đổ', cell.risks.treeFall, kDisasterColors['tree_fall']!),
      ('Nắng nóng', cell.risks.heatwave, kDisasterColors['heatwave']!),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(icon: Icons.analytics, title: 'Mức nguy cơ chi tiết'),
          const SizedBox(height: 12),
          ...riskItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(item.$1,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        Text('${(item.$2 * 100).toStringAsFixed(0)}%',
                            style: TextStyle(color: item.$3, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: item.$2,
                      backgroundColor: item.$3.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(item.$3),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String type) {
    final actions = _getActionAdvice(type, cell.alertLevel);
    return _Card(
      color: (cell.alertLevel == 'red' ? kColorRed : kColorYellow).withOpacity(0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.campaign,
            title: 'Khuyến cáo hành động',
            color: cell.alertLevel == 'red' ? kColorRed : kColorYellow,
          ),
          const SizedBox(height: 8),
          ...actions.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(a, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => NotificationService.speakAlert(_getAlertMessage()),
            icon: const Icon(Icons.volume_up),
            label: const Text('Nghe cảnh báo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ForecastScreen(cellId: cell.cellId, district: cell.district)),
            ),
            icon: const Icon(Icons.show_chart),
            label: const Text('Xem dự báo 72h'),
            style: OutlinedButton.styleFrom(
              foregroundColor: kPrimaryColor,
              side: const BorderSide(color: kPrimaryColor),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  String _getAlertMessage() {
    final type = kDisasterLabels[cell.risks.dominantType] ?? 'thiên tai';
    final level = cell.alertLevel == 'red' ? 'đỏ' : 'vàng';
    return 'Cảnh báo $level. $type tại ${cell.district}. '
        'Mức nguy cơ ${(cell.risks.maxRisk * 100).toStringAsFixed(0)} phần trăm. '
        '${_getActionAdvice(cell.risks.dominantType, cell.alertLevel).first}';
  }

  List<String> _getActionAdvice(String type, String level) {
    final isRed = level == 'red';
    switch (type) {
      case 'landslide':
        return isRed
            ? ['Di chuyển ngay khỏi vùng đồi, núi và taluy', 'Tránh xa ven sông, suối và khu vực dốc cao', 'Thông báo cho hàng xóm, gọi 1800 599 920']
            : ['Hạn chế đến khu vực sườn đồi, đặc biệt khi trời mưa', 'Theo dõi cảnh báo và chuẩn bị sơ tán nếu cần'];
      case 'flood':
        return isRed
            ? ['Chuyển đồ vật lên cao ngay lập tức', 'Di chuyển đến nơi cao ráo, an toàn', 'Không lội qua dòng nước chảy mạnh']
            : ['Theo dõi mực nước sông, suối', 'Chuẩn bị di chuyển tài sản lên cao', 'Giữ liên lạc với hàng xóm'];
      case 'storm':
        return isRed
            ? ['Ở trong nhà, đóng cửa chắc chắn', 'Tránh xa cây to, cột điện và mái tôn', 'Tích trữ nước uống và thức ăn khô']
            : ['Gia cố nhà cửa, cắt cành cây gần nhà', 'Hạn chế ra ngoài khi không cần thiết'];
      case 'tree_fall':
        return isRed
            ? ['Không đứng gần cây to, cột điện', 'Không đỗ xe dưới tán cây lớn', 'Di chuyển vào trong nhà']
            : ['Tránh đi dưới tán cây cao khi có gió', 'Chú ý quan sát khi đi bộ trên đường'];
      case 'heatwave':
        return isRed
            ? ['Không ra ngoài từ 10h-16h', 'Uống ít nhất 2-3 lít nước mỗi ngày', 'Quan tâm đến người già, trẻ nhỏ']
            : ['Mặc quần áo nhẹ, thoáng mát', 'Uống đủ nước, tránh rượu bia', 'Nghỉ ngơi trong bóng mát'];
      default:
        return ['Theo dõi thông tin cảnh báo', 'Liên hệ chính quyền địa phương nếu cần'];
    }
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final Color? color;
  const _Card({required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  const _CardTitle({required this.icon, required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? kPrimaryColor;
    return Row(
      children: [
        Icon(icon, size: 18, color: c),
        const SizedBox(width: 6),
        Text(title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c)),
      ],
    );
  }
}

class _WeatherItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _WeatherItem(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blueGrey),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
