import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../config/constants.dart';
import '../models/risk_data.dart';
import '../providers/risk_provider.dart';
import '../providers/alert_provider.dart';
import '../widgets/risk_map_layer.dart';
import '../widgets/disaster_filter_bar.dart';
import '../widgets/alert_level_badge.dart';
import '../widgets/risk_legend.dart';
import 'alert_detail_screen.dart';
import 'report_screen.dart';
import 'alert_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _mapController = MapController();
  Position? _userPosition;
  Timer? _refreshTimer;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final riskProvider = context.read<RiskProvider>();
    final alertProvider = context.read<AlertProvider>();

    await riskProvider.checkBackend();
    await alertProvider.loadActiveAlerts(notify: true);
    await _loadUserLocation();
    _loadMapData();

    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _loadMapData();
      alertProvider.loadActiveAlerts(notify: true);
    });
  }

  Future<void> _loadUserLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      setState(() => _userPosition = pos);
      if (mounted && _mapReady) {
        _mapController.move(LatLng(pos.latitude, pos.longitude), kDefaultZoom);
      }
      await context.read<RiskProvider>().loadCurrentLocationRisk(
          pos.latitude, pos.longitude);
    } catch (_) {}
  }

  void _loadMapData() {
    if (!_mapReady) return;
    final bounds = _mapController.camera.visibleBounds;
    context.read<RiskProvider>().loadAreaRisks(
          minLat: bounds.south - 0.05,
          maxLat: bounds.north + 0.05,
          minLng: bounds.west - 0.05,
          maxLng: bounds.east + 0.05,
        );
  }

  void _onCellTap(GridCell cell) {
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => AlertDetailScreen(cell: cell)));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          // Top overlay: TopBar + FilterBar gộp thành một Column
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 6),
                  _buildFilterBar(),
                ],
              ),
            ),
          ),
          _buildBottomInfo(),
          _buildFABs(),
          // Risk legend (left side)
          Positioned(
            left: 12,
            bottom: 90,
            child: Consumer<RiskProvider>(
              builder: (_, prov, __) =>
                  prov.areaCells.isNotEmpty ? const RiskLegend() : const SizedBox.shrink(),
            ),
          ),
          if (!context.watch<RiskProvider>().backendOnline)
            _buildOfflineBanner(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Consumer<RiskProvider>(
      builder: (context, provider, _) => FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(kDefaultLat, kDefaultLng),
          initialZoom: kDefaultZoom,
          onMapReady: () {
            setState(() => _mapReady = true);
            _loadMapData();
          },
          onPositionChanged: (pos, hasGesture) {
            if (hasGesture) _loadMapData();
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.alertvn.app',
          ),
          RiskMapLayer(
            cells: provider.areaCells,
            onCellTap: _onCellTap,
            activeFilter: provider.activeFilter,
          ),
          if (_userPosition != null)
            MarkerLayer(markers: [
              Marker(
                point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
                width: 20,
                height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blue.withOpacity(0.4), blurRadius: 8)
                    ],
                  ),
                ),
              ),
            ]),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AlertVN',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Phú Thọ',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Consumer<RiskProvider>(
              builder: (_, prov, __) => prov.loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: kPrimaryColor))
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
            Consumer<AlertProvider>(
              builder: (_, alertProv, __) => GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const AlertListScreen())),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_rounded,
                        size: 28, color: Colors.grey),
                    if (alertProv.redCount > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                              color: kColorRed, shape: BoxShape.circle),
                          child: Center(
                            child: Text('${alertProv.redCount}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Consumer<RiskProvider>(
          builder: (_, provider, __) => DisasterFilterBar(
            activeFilter: provider.activeFilter,
            onFilterChanged: provider.setFilter,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Positioned(
      bottom: 16,
      left: 12,
      right: 80,
      child: Consumer<RiskProvider>(
        builder: (_, provider, __) {
          final risk = provider.currentLocationRisk;
          if (risk == null) return const SizedBox.shrink();
          return GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => AlertDetailScreen(cell: risk))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.12), blurRadius: 12)
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      color: kPrimaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(risk.district,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(
                          '${risk.temperature.toStringAsFixed(1)}°C  •  Gió ${risk.windSpeed.toStringAsFixed(0)} km/h',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  AlertLevelBadge(level: risk.alertLevel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFABs() {
    return Positioned(
      bottom: 16,
      right: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'location',
            onPressed: _loadUserLocation,
            backgroundColor: Colors.white,
            elevation: 4,
            child: const Icon(Icons.my_location, color: kPrimaryColor),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'report',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportScreen()),
            ),
            backgroundColor: kPrimaryColor,
            elevation: 4,
            child: const Icon(Icons.add_alert, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.grey[800],
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Backend offline – dữ liệu cached',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
