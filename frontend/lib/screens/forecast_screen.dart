import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/constants.dart';
import '../models/community_report.dart';
import '../services/api_service.dart';

class ForecastScreen extends StatefulWidget {
  final String cellId;
  final String district;

  const ForecastScreen({super.key, required this.cellId, required this.district});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  List<ForecastPoint> _points = [];
  bool _loading = true;
  String? _error;
  String _selectedType = 'landslide';

  final _types = [
    ('storm', 'Bão'),
    ('flood', 'Lũ lụt'),
    ('landslide', 'Sạt lở'),
    ('tree_fall', 'Cây đổ'),
    ('heatwave', 'Nắng nóng'),
  ];

  @override
  void initState() {
    super.initState();
    _loadForecast();
  }

  Future<void> _loadForecast() async {
    setState(() { _loading = true; _error = null; });
    final data = await ApiService.getForecast(widget.cellId, 72);
    if (!mounted) return;
    if (data.isEmpty) {
      setState(() { _loading = false; _error = 'Không thể tải dự báo'; });
    } else {
      setState(() { _loading = false; _points = data; });
    }
  }

  double _getScore(ForecastPoint p) {
    return switch (_selectedType) {
      'storm' => p.storm,
      'flood' => p.flood,
      'landslide' => p.landslide,
      'tree_fall' => p.treeFall,
      'heatwave' => p.heatwave,
      _ => p.landslide,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = kDisasterColors[_selectedType] ?? kPrimaryColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('Dự báo – ${widget.district}'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTypeChips(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!, style: const TextStyle(color: Colors.grey)))
                    : _buildChart(color),
          ),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildTypeChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.grey[50],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _types.map((t) {
            final isSelected = _selectedType == t.$1;
            final c = kDisasterColors[t.$1]!;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(t.$2),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedType = t.$1),
                selectedColor: c,
                labelStyle: TextStyle(color: isSelected ? Colors.white : c, fontWeight: FontWeight.w600),
                side: BorderSide(color: c),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChart(Color color) {
    if (_points.isEmpty) return const Center(child: Text('Không có dữ liệu'));

    final spots = _points.asMap().entries.map((e) {
      return FlSpot(e.value.hour.toDouble(), _getScore(e.value) * 100);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xác suất nguy cơ trong 72 giờ tới',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            kDisasterLabels[_selectedType] ?? _selectedType,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 20,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}%',
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 12,
                      getTitlesWidget: (v, _) {
                        final h = v.toInt();
                        return Text('+${h}h', style: const TextStyle(fontSize: 11, color: Colors.grey));
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 72,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.15),
                    ),
                    dotData: const FlDotData(show: false),
                  ),
                ],
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(y: 70, color: kColorRed.withOpacity(0.6),
                        strokeWidth: 1.5, dashArray: [6, 4],
                        label: HorizontalLineLabel(show: true, labelResolver: (_) => 'Đỏ',
                            style: const TextStyle(color: kColorRed, fontSize: 11))),
                    HorizontalLine(y: 40, color: kColorYellow.withOpacity(0.6),
                        strokeWidth: 1.5, dashArray: [6, 4],
                        label: HorizontalLineLabel(show: true, labelResolver: (_) => 'Vàng',
                            style: const TextStyle(color: kColorYellow, fontSize: 11))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.grey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LegendItem(kColorRed, '≥70% Nguy hiểm'),
          const SizedBox(width: 20),
          _LegendItem(kColorYellow, '40-70% Chú ý'),
          const SizedBox(width: 20),
          _LegendItem(kColorGreen, '<40% An toàn'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem(this.color, this.label);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(width: 12, height: 3, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      );
}
