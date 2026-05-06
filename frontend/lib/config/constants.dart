import 'package:flutter/material.dart';

// Physical device: uses PC's WiFi IP (192.168.1.95)
// Emulator: uses 10.0.2.2 (loopback alias)
const String kBackendUrl = 'http://192.168.1.95:8000';

// Phu Tho center coordinates
const double kDefaultLat = 21.35;
const double kDefaultLng = 105.0;
const double kDefaultZoom = 10.0;

// Alert level colors
const Color kColorGreen = Color(0xFF4CAF50);
const Color kColorYellow = Color(0xFFFFC107);
const Color kColorRed = Color(0xFFF44336);
const Color kColorGreenBg = Color(0x334CAF50);
const Color kColorYellowBg = Color(0x33FFC107);
const Color kColorRedBg = Color(0x33F44336);

// App theme
const Color kPrimaryColor = Color(0xFFD32F2F);
const Color kSecondaryColor = Color(0xFFFF7043);
const Color kSurfaceColor = Color(0xFFFAFAFA);

// Disaster type labels
const Map<String, String> kDisasterLabels = {
  'storm': 'Bão',
  'flood': 'Lũ lụt',
  'landslide': 'Sạt lở',
  'tree_fall': 'Cây đổ',
  'heatwave': 'Nắng nóng',
};

const Map<String, IconData> kDisasterIcons = {
  'storm': Icons.tornado,
  'flood': Icons.water,
  'landslide': Icons.landslide,
  'tree_fall': Icons.park,
  'heatwave': Icons.wb_sunny,
};

const Map<String, Color> kDisasterColors = {
  'storm': Color(0xFF5C6BC0),
  'flood': Color(0xFF1976D2),
  'landslide': Color(0xFF795548),
  'tree_fall': Color(0xFF388E3C),
  'heatwave': Color(0xFFFF6F00),
};

// Emergency contacts
const String kEmergencyNumber = '1800 599 920';
const String kPoliceNumber = '113';
const String kFireNumber = '114';
const String kMedicalNumber = '115';
