class AlertModel {
  final int alertId;
  final String disasterType;
  final String level;
  final String district;
  final String commune;
  final double riskScore;
  final String messageVi;
  final DateTime? triggeredAt;
  final bool isActive;

  const AlertModel({
    required this.alertId,
    required this.disasterType,
    required this.level,
    required this.district,
    required this.commune,
    required this.riskScore,
    required this.messageVi,
    this.triggeredAt,
    required this.isActive,
  });

  factory AlertModel.fromJson(Map<String, dynamic> j) => AlertModel(
        alertId: j['alert_id'] ?? 0,
        disasterType: j['disaster_type'] ?? '',
        level: j['level'] ?? 'yellow',
        district: j['district'] ?? '',
        commune: j['commune'] ?? '',
        riskScore: (j['risk_score'] ?? 0).toDouble(),
        messageVi: j['message_vi'] ?? '',
        triggeredAt: j['triggered_at'] != null
            ? DateTime.tryParse(j['triggered_at'])
            : null,
        isActive: j['is_active'] ?? true,
      );
}
