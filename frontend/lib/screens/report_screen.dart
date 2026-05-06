import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../config/constants.dart';
import '../models/community_report.dart';
import '../services/api_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedType = 'landslide';
  final _descController = TextEditingController();
  LatLng _selectedLocation = const LatLng(kDefaultLat, kDefaultLng);
  bool _submitting = false;

  final _types = [
    ('landslide', 'Sạt lở đất', Icons.landslide, Color(0xFF795548)),
    ('flood', 'Lũ lụt / ngập', Icons.water, Color(0xFF1976D2)),
    ('tree_fall', 'Cây đổ', Icons.park, Color(0xFF388E3C)),
    ('other', 'Khác', Icons.warning_rounded, Color(0xFF9E9E9E)),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (mounted) {
        setState(() {
          _selectedLocation = LatLng(pos.latitude, pos.longitude);
        });
      }
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng mô tả sự cố')),
      );
      return;
    }
    setState(() => _submitting = true);

    final report = CommunityReport(
      disasterType: _selectedType,
      lat: _selectedLocation.latitude,
      lng: _selectedLocation.longitude,
      description: _descController.text.trim(),
      status: 'pending',
      confirmCount: 0,
    );

    final result = await ApiService.submitReport(report);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Báo cáo đã được gửi thành công! Cảm ơn bạn.'),
          backgroundColor: kColorGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể gửi báo cáo. Kiểm tra kết nối mạng.'),
          backgroundColor: kColorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo sự cố'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 16),
            _buildLocationPicker(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Loại sự cố', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10, runSpacing: 8,
          children: _types.map((t) {
            final isSelected = _selectedType == t.$1;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? t.$4 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: t.$4, width: 1.5),
                  boxShadow: isSelected
                      ? [BoxShadow(color: t.$4.withOpacity(0.3), blurRadius: 6)]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.$3, size: 20, color: isSelected ? Colors.white : t.$4),
                    const SizedBox(width: 6),
                    Text(t.$2,
                        style: TextStyle(
                            color: isSelected ? Colors.white : t.$4,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vị trí sự cố', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 4),
        Text(
          'Nhấn vào bản đồ để đánh dấu vị trí chính xác',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 13,
              onTap: (_, latLng) => setState(() => _selectedLocation = latLng),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.alertvn.app',
              ),
              MarkerLayer(markers: [
                Marker(
                  point: _selectedLocation,
                  width: 36, height: 36,
                  child: const Icon(Icons.location_pin, color: kPrimaryColor, size: 36),
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_selectedLocation.latitude.toStringAsFixed(5)}°N, ${_selectedLocation.longitude.toStringAsFixed(5)}°E',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mô tả sự cố', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
          controller: _descController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Mô tả ngắn gọn tình hình (ví dụ: Có vết nứt trên mái dốc, nước chảy mạnh...)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimaryColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _submitting ? null : _submit,
        icon: _submitting
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.send),
        label: Text(_submitting ? 'Đang gửi...' : 'Gửi báo cáo'),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }
}
