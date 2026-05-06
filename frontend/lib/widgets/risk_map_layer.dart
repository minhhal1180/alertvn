import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/risk_data.dart';

// Windy-like color gradient: low (cyan) → moderate (yellow) → high (red) → extreme (purple)
Color riskColor(double score) {
  const stops = [
    (0.08, Color(0xFF00E5FF)),  // cyan
    (0.25, Color(0xFF00E676)),  // green
    (0.42, Color(0xFFFFEA00)),  // yellow
    (0.58, Color(0xFFFF6D00)),  // orange
    (0.72, Color(0xFFFF1744)),  // red
    (0.87, Color(0xFFD500F9)),  // purple
    (1.00, Color(0xFF6200EA)),  // deep purple
  ];
  for (int i = 0; i < stops.length - 1; i++) {
    if (score <= stops[i + 1].$1) {
      final t = (score - stops[i].$1) / (stops[i + 1].$1 - stops[i].$1);
      return Color.lerp(stops[i].$2, stops[i + 1].$2, t.clamp(0.0, 1.0))!;
    }
  }
  return const Color(0xFF6200EA);
}

class RiskMapLayer extends StatelessWidget {
  final List<GridCell> cells;
  final Function(GridCell)? onCellTap;
  final String? activeFilter;

  const RiskMapLayer({
    super.key,
    required this.cells,
    this.onCellTap,
    this.activeFilter,
  });

  double _score(GridCell c) => switch (activeFilter) {
        'storm' => c.risks.storm,
        'flood' => c.risks.flood,
        'landslide' => c.risks.landslide,
        'tree_fall' => c.risks.treeFall,
        'heatwave' => c.risks.heatwave,
        _ => c.risks.maxRisk,
      };

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final visible = cells.where((c) => _score(c) >= 0.08).toList();
    final highRisk = cells.where((c) => _score(c) >= 0.68).toList();

    return Stack(
      children: [
        // Smooth heatmap layer
        CustomPaint(
          painter: _HeatmapPainter(
            cells: visible,
            camera: camera,
            activeFilter: activeFilter,
          ),
          child: const SizedBox.expand(),
        ),
        // Tappable warning markers for high-risk cells
        MarkerLayer(
          markers: highRisk
              .map((cell) => Marker(
                    point: LatLng(cell.centerLat, cell.centerLng),
                    width: 34,
                    height: 34,
                    child: GestureDetector(
                      onTap: () => onCellTap?.call(cell),
                      child: _WarningMarker(score: _score(cell)),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _WarningMarker extends StatelessWidget {
  final double score;
  const _WarningMarker({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = riskColor(score);
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.55), blurRadius: 10, spreadRadius: 2)
        ],
      ),
      child: const Icon(Icons.warning_rounded, color: Colors.white, size: 18),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final List<GridCell> cells;
  final MapCamera camera;
  final String? activeFilter;

  _HeatmapPainter({
    required this.cells,
    required this.camera,
    this.activeFilter,
  });

  double _score(GridCell c) => switch (activeFilter) {
        'storm' => c.risks.storm,
        'flood' => c.risks.flood,
        'landslide' => c.risks.landslide,
        'tree_fall' => c.risks.treeFall,
        'heatwave' => c.risks.heatwave,
        _ => c.risks.maxRisk,
      };

  @override
  void paint(Canvas canvas, Size size) {
    if (cells.isEmpty) return;

    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);
    final centerPx = camera.project(camera.center);
    final originX = centerPx.x - size.width / 2;
    final originY = centerPx.y - size.height / 2;

    // Cell ≈ 0.011° wide. Blob radius = 2.5 × cell for smooth overlap.
    final cellPx = 0.011 * 256 * pow(2.0, camera.zoom) / 360.0;
    final radius = (cellPx * 2.5).clamp(10.0, 120.0);

    // All blobs go into an offscreen layer; dstIn caps total opacity at 60%
    // → map tiles always visible underneath at ≥40% regardless of cell density.
    canvas.saveLayer(bounds, Paint());

    for (final cell in cells) {
      final score = _score(cell);
      final pt = camera.project(LatLng(cell.centerLat, cell.centerLng));
      final dx = (pt.x - originX).toDouble();
      final dy = (pt.y - originY).toDouble();

      if (dx < -radius || dx > size.width + radius) continue;
      if (dy < -radius || dy > size.height + radius) continue;

      final color = riskColor(score);
      // Inner-layer opacity (before global 60% cap)
      final inner = (score * 0.82 + 0.20).clamp(0.22, 1.0);
      final offset = Offset(dx, dy);

      canvas.drawCircle(
        offset,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withOpacity(inner),
              color.withOpacity(inner * 0.42),
              Colors.transparent,
            ],
            stops: const [0.0, 0.42, 1.0],
          ).createShader(Rect.fromCircle(center: offset, radius: radius)),
      );
    }

    // dstIn mask: each pixel's alpha = drawn_alpha × 0.60
    // Dense areas max out at 60%, sparse/edge areas stay lower → map visible
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..color = const Color(0x99FFFFFF), // 0x99 = 153 ≈ 60%
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) =>
      old.cells.length != cells.length ||
      old.camera != camera ||
      old.activeFilter != activeFilter;
}
