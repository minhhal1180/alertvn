import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _voiceEnabled = true;
  String _language = 'vi';
  double _alertThreshold = 0.4;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushEnabled = prefs.getBool('push_enabled') ?? true;
      _voiceEnabled = prefs.getBool('voice_enabled') ?? true;
      _language = prefs.getString('language') ?? 'vi';
      _alertThreshold = prefs.getDouble('alert_threshold') ?? 0.4;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_enabled', _pushEnabled);
    await prefs.setBool('voice_enabled', _voiceEnabled);
    await prefs.setString('language', _language);
    await prefs.setDouble('alert_threshold', _alertThreshold);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu cài đặt'), backgroundColor: kColorGreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Thông báo', [
            SwitchListTile(
              title: const Text('Thông báo đẩy'),
              subtitle: const Text('Nhận push notification khi có cảnh báo'),
              value: _pushEnabled,
              onChanged: (v) => setState(() => _pushEnabled = v),
              activeThumbColor: kPrimaryColor,
            ),
            SwitchListTile(
              title: const Text('Cảnh báo giọng nói'),
              subtitle: const Text('Đọc to cảnh báo khi cấp độ đỏ'),
              value: _voiceEnabled,
              onChanged: (v) => setState(() => _voiceEnabled = v),
              activeThumbColor: kPrimaryColor,
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection('Ngôn ngữ', [
            RadioListTile<String>(
              title: const Text('Tiếng Việt'),
              value: 'vi',
              groupValue: _language,
              onChanged: (v) => setState(() => _language = v!),
              activeColor: kPrimaryColor,
            ),
            RadioListTile<String>(
              title: const Text('Tiếng Mường (sắp có)'),
              subtitle: const Text('Đang phát triển'),
              value: 'muong',
              groupValue: _language,
              onChanged: null,
              activeColor: kPrimaryColor,
            ),
            RadioListTile<String>(
              title: const Text('Tiếng Tày (sắp có)'),
              subtitle: const Text('Đang phát triển'),
              value: 'tay',
              groupValue: _language,
              onChanged: null,
              activeColor: kPrimaryColor,
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection('Ngưỡng cảnh báo', [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ngưỡng hiện tại: ${(_alertThreshold * 100).toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nhận thông báo khi nguy cơ ≥ ${(_alertThreshold * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Slider(
                    value: _alertThreshold,
                    min: 0.2,
                    max: 0.7,
                    divisions: 10,
                    label: '${(_alertThreshold * 100).toInt()}%',
                    activeColor: kPrimaryColor,
                    onChanged: (v) => setState(() => _alertThreshold = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('20% (nhạy hơn)', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                      Text('70% (ít hơn)', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSection('Thông tin', [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('AlertVN'),
              subtitle: const Text('v1.0.0 – Demo Phú Thọ'),
            ),
            ListTile(
              leading: const Icon(Icons.source),
              title: const Text('Nguồn dữ liệu'),
              subtitle: const Text('OpenWeatherMap, NASA SRTM, GDACS'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold,
                    color: kPrimaryColor, letterSpacing: 0.5)),
          ),
          ...children,
        ],
      ),
    );
  }
}
