import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/alert_provider.dart';
import '../models/alert.dart';
import '../widgets/alert_level_badge.dart';
import 'package:intl/intl.dart';

class AlertListScreen extends StatefulWidget {
  const AlertListScreen({super.key});

  @override
  State<AlertListScreen> createState() => _AlertListScreenState();
}

class _AlertListScreenState extends State<AlertListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertProvider>().loadActiveAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cảnh báo đang hiệu lực'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AlertProvider>().loadActiveAlerts(),
          ),
        ],
      ),
      body: Consumer<AlertProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.activeAlerts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: kColorGreen),
                  SizedBox(height: 16),
                  Text('Không có cảnh báo nào', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text('Tình trạng an toàn', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: provider.activeAlerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _AlertCard(alert: provider.activeAlerts[i]),
          );
        },
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;
  const _AlertCard({required this.alert});

  @override
  Widget build(BuildContext context) {
    final color = kDisasterColors[alert.disasterType] ?? kPrimaryColor;
    final icon = kDisasterIcons[alert.disasterType] ?? Icons.warning_rounded;
    final label = kDisasterLabels[alert.disasterType] ?? alert.disasterType;
    final timeStr = alert.triggeredAt != null
        ? DateFormat('HH:mm dd/MM').format(alert.triggeredAt!.toLocal())
        : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
              const Spacer(),
              AlertLevelBadge(level: alert.level),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('${alert.district} – ${alert.commune}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(alert.messageVi, style: const TextStyle(fontSize: 13)),
          if (timeStr.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Cảnh báo lúc: $timeStr',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}
