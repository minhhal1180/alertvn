class CommunityReport {
  final int? reportId;
  final String disasterType;
  final double lat;
  final double lng;
  final String description;
  final String status;
  final int confirmCount;
  final DateTime? createdAt;

  const CommunityReport({
    this.reportId,
    required this.disasterType,
    required this.lat,
    required this.lng,
    required this.description,
    required this.status,
    required this.confirmCount,
    this.createdAt,
  });

  factory CommunityReport.fromJson(Map<String, dynamic> j) => CommunityReport(
        reportId: j['report_id'],
        disasterType: j['disaster_type'] ?? '',
        lat: (j['lat'] ?? 0).toDouble(),
        lng: (j['lng'] ?? 0).toDouble(),
        description: j['description'] ?? '',
        status: j['status'] ?? 'pending',
        confirmCount: j['confirm_count'] ?? 0,
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'disaster_type': disasterType,
        'lat': lat,
        'lng': lng,
        'description': description,
      };
}

class ForecastPoint {
  final int hour;
  final double storm;
  final double flood;
  final double landslide;
  final double treeFall;
  final double heatwave;

  const ForecastPoint({
    required this.hour,
    required this.storm,
    required this.flood,
    required this.landslide,
    required this.treeFall,
    required this.heatwave,
  });

  factory ForecastPoint.fromJson(Map<String, dynamic> j) {
    final risks = j['risks'] ?? {};
    return ForecastPoint(
      hour: j['hour'] ?? 0,
      storm: (risks['storm'] ?? 0).toDouble(),
      flood: (risks['flood'] ?? 0).toDouble(),
      landslide: (risks['landslide'] ?? 0).toDouble(),
      treeFall: (risks['tree_fall'] ?? 0).toDouble(),
      heatwave: (risks['heatwave'] ?? 0).toDouble(),
    );
  }
}
