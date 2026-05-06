import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/alert.dart';
import '../config/constants.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static final _tts = FlutterTts();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    await _tts.setLanguage('vi-VN');
    await _tts.setSpeechRate(0.85);
    await _tts.setVolume(1.0);
    _initialized = true;
  }

  static Future<void> showAlertNotification(AlertModel alert) async {
    final levelLabel = alert.level == 'red' ? 'ĐỎ' : 'VÀNG';
    final disasterLabel = kDisasterLabels[alert.disasterType] ?? alert.disasterType;

    const details = AndroidNotificationDetails(
      'alertvn_channel',
      'AlertVN Cảnh báo',
      channelDescription: 'Cảnh báo thiên tai từ AlertVN',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    await _plugin.show(
      alert.alertId,
      '⚠️ Cảnh báo $levelLabel: $disasterLabel',
      '${alert.district} – ${alert.commune}',
      const NotificationDetails(android: details),
    );
  }

  static Future<void> speakAlert(String message) async {
    await _tts.stop();
    await _tts.speak(message);
  }

  static Future<void> stopTts() async {
    await _tts.stop();
  }
}
