import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class AlertProvider extends ChangeNotifier {
  List<AlertModel> _activeAlerts = [];
  bool _loading = false;

  List<AlertModel> get activeAlerts => _activeAlerts;
  bool get loading => _loading;
  int get redCount => _activeAlerts.where((a) => a.level == 'red').length;
  int get yellowCount => _activeAlerts.where((a) => a.level == 'yellow').length;

  Future<void> loadActiveAlerts({bool notify = false}) async {
    _loading = true;
    notifyListeners();

    final alerts = await ApiService.getActiveAlerts();
    final prevIds = _activeAlerts.map((a) => a.alertId).toSet();

    _activeAlerts = alerts;
    _loading = false;
    notifyListeners();

    if (notify) {
      for (final alert in alerts) {
        if (!prevIds.contains(alert.alertId)) {
          await NotificationService.showAlertNotification(alert);
        }
      }
    }
  }
}
