import 'package:flutter/material.dart';
import '../models/risk_data.dart';
import '../services/api_service.dart';

class RiskProvider extends ChangeNotifier {
  List<GridCell> _areaCells = [];
  RiskDetail? _currentLocationRisk;
  bool _loading = false;
  String? _error;
  bool _backendOnline = false;

  // Active disaster type filter (null = show all)
  String? _activeFilter;

  List<GridCell> get areaCells {
    if (_activeFilter == null) return _areaCells;
    return _areaCells.where((c) {
      final score = _getRiskByType(c.risks, _activeFilter!);
      return score > 0.05;
    }).toList();
  }

  RiskDetail? get currentLocationRisk => _currentLocationRisk;
  bool get loading => _loading;
  String? get error => _error;
  bool get backendOnline => _backendOnline;
  String? get activeFilter => _activeFilter;

  void setFilter(String? type) {
    _activeFilter = (_activeFilter == type) ? null : type;
    notifyListeners();
  }

  double _getRiskByType(RiskScore r, String type) {
    switch (type) {
      case 'storm': return r.storm;
      case 'flood': return r.flood;
      case 'landslide': return r.landslide;
      case 'tree_fall': return r.treeFall;
      case 'heatwave': return r.heatwave;
      default: return r.maxRisk;
    }
  }

  Future<void> checkBackend() async {
    _backendOnline = await ApiService.checkBackend();
    notifyListeners();
  }

  Future<void> loadAreaRisks({
    required double minLat, required double maxLat,
    required double minLng, required double maxLng,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _areaCells = await ApiService.getRisksInArea(
        minLat: minLat, maxLat: maxLat,
        minLng: minLng, maxLng: maxLng,
      );
      _error = null;
    } catch (e) {
      _error = 'Không thể tải dữ liệu: $e';
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadCurrentLocationRisk(double lat, double lng) async {
    final detail = await ApiService.getRiskAtLocation(lat, lng);
    if (detail != null) {
      _currentLocationRisk = detail;
      notifyListeners();
    }
  }
}
