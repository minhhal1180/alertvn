class RiskScore {
  final double storm;
  final double flood;
  final double landslide;
  final double treeFall;
  final double heatwave;

  const RiskScore({
    this.storm = 0,
    this.flood = 0,
    this.landslide = 0,
    this.treeFall = 0,
    this.heatwave = 0,
  });

  factory RiskScore.fromJson(Map<String, dynamic> j) => RiskScore(
        storm: (j['storm'] ?? 0).toDouble(),
        flood: (j['flood'] ?? 0).toDouble(),
        landslide: (j['landslide'] ?? 0).toDouble(),
        treeFall: (j['tree_fall'] ?? 0).toDouble(),
        heatwave: (j['heatwave'] ?? 0).toDouble(),
      );

  double get maxRisk => [storm, flood, landslide, treeFall, heatwave]
      .reduce((a, b) => a > b ? a : b);

  String get dominantType {
    final map = {
      'storm': storm,
      'flood': flood,
      'landslide': landslide,
      'tree_fall': treeFall,
      'heatwave': heatwave,
    };
    return map.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

class GridCell {
  final String cellId;
  final double centerLat;
  final double centerLng;
  final String district;
  final String commune;
  final RiskScore risks;
  final String alertLevel; // green / yellow / red
  final double temperature;
  final double rain24h;
  final double windSpeed;

  const GridCell({
    required this.cellId,
    required this.centerLat,
    required this.centerLng,
    required this.district,
    required this.commune,
    required this.risks,
    required this.alertLevel,
    required this.temperature,
    required this.rain24h,
    required this.windSpeed,
  });

  factory GridCell.fromJson(Map<String, dynamic> j) => GridCell(
        cellId: j['cell_id'] ?? '',
        centerLat: (j['center_lat'] ?? 0).toDouble(),
        centerLng: (j['center_lng'] ?? 0).toDouble(),
        district: j['district'] ?? '',
        commune: j['commune'] ?? '',
        risks: RiskScore.fromJson(j['risks'] ?? {}),
        alertLevel: j['alert_level'] ?? 'green',
        temperature: (j['temperature'] ?? 25).toDouble(),
        rain24h: (j['rain_24h'] ?? 0).toDouble(),
        windSpeed: (j['wind_speed'] ?? 0).toDouble(),
      );
}

class RiskDetail extends GridCell {
  final double rain72h;
  final double rain7d;
  final double humidity;
  final double elevation;
  final double slope;

  const RiskDetail({
    required super.cellId,
    required super.centerLat,
    required super.centerLng,
    required super.district,
    required super.commune,
    required super.risks,
    required super.alertLevel,
    required super.temperature,
    required super.rain24h,
    required super.windSpeed,
    required this.rain72h,
    required this.rain7d,
    required this.humidity,
    required this.elevation,
    required this.slope,
  });

  factory RiskDetail.fromJson(Map<String, dynamic> j) => RiskDetail(
        cellId: j['cell_id'] ?? '',
        centerLat: (j['center_lat'] ?? 0).toDouble(),
        centerLng: (j['center_lng'] ?? 0).toDouble(),
        district: j['district'] ?? '',
        commune: j['commune'] ?? '',
        risks: RiskScore.fromJson(j['risks'] ?? {}),
        alertLevel: j['alert_level'] ?? 'green',
        temperature: (j['temperature'] ?? 25).toDouble(),
        rain24h: (j['rain_24h'] ?? 0).toDouble(),
        windSpeed: (j['wind_speed'] ?? 0).toDouble(),
        rain72h: (j['rain_72h'] ?? 0).toDouble(),
        rain7d: (j['rain_7d'] ?? 0).toDouble(),
        humidity: (j['humidity'] ?? 70).toDouble(),
        elevation: (j['elevation'] ?? 0).toDouble(),
        slope: (j['slope'] ?? 0).toDouble(),
      );
}
