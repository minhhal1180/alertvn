import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/risk_data.dart';
import '../models/alert.dart';
import '../models/community_report.dart';

class ApiService {
  static const _timeout = Duration(seconds: 10);

  static Future<RiskDetail?> getRiskAtLocation(double lat, double lng) async {
    try {
      final uri = Uri.parse('$kBackendUrl/api/v1/risks/$lat/$lng');
      final resp = await http.get(uri).timeout(_timeout);
      if (resp.statusCode == 200) {
        return RiskDetail.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      }
    } catch (_) {}
    return null;
  }

  static Future<List<GridCell>> getRisksInArea({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
  }) async {
    try {
      final uri = Uri.parse('$kBackendUrl/api/v1/risks/area').replace(queryParameters: {
        'min_lat': minLat.toString(),
        'max_lat': maxLat.toString(),
        'min_lng': minLng.toString(),
        'max_lng': maxLng.toString(),
      });
      final resp = await http.get(uri).timeout(_timeout);
      if (resp.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resp.bodyBytes));
        final cells = data['cells'] as List;
        return cells.map((c) => GridCell.fromJson(c)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<AlertModel>> getActiveAlerts() async {
    try {
      final uri = Uri.parse('$kBackendUrl/api/v1/alerts/active');
      final resp = await http.get(uri).timeout(_timeout);
      if (resp.statusCode == 200) {
        final list = jsonDecode(utf8.decode(resp.bodyBytes)) as List;
        return list.map((a) => AlertModel.fromJson(a)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<CommunityReport?> submitReport(CommunityReport report) async {
    try {
      final uri = Uri.parse('$kBackendUrl/api/v1/reports');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(report.toJson()),
      ).timeout(_timeout);
      if (resp.statusCode == 201) {
        return CommunityReport.fromJson(jsonDecode(utf8.decode(resp.bodyBytes)));
      }
    } catch (_) {}
    return null;
  }

  static Future<List<CommunityReport>> getReports({String status = 'verified'}) async {
    try {
      final uri = Uri.parse('$kBackendUrl/api/v1/reports')
          .replace(queryParameters: {'status': status});
      final resp = await http.get(uri).timeout(_timeout);
      if (resp.statusCode == 200) {
        final list = jsonDecode(utf8.decode(resp.bodyBytes)) as List;
        return list.map((r) => CommunityReport.fromJson(r)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<ForecastPoint>> getForecast(String cellId, int hours) async {
    try {
      final uri = Uri.parse('$kBackendUrl/api/v1/forecast/$cellId/$hours');
      final resp = await http.get(uri).timeout(_timeout);
      if (resp.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resp.bodyBytes));
        final list = data['forecast'] as List;
        return list.map((p) => ForecastPoint.fromJson(p)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> checkBackend() async {
    try {
      final resp = await http.get(Uri.parse('$kBackendUrl/health')).timeout(_timeout);
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
