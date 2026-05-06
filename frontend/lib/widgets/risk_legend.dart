import 'package:flutter/material.dart';

class RiskLegend extends StatelessWidget {
  const RiskLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Cao',
              style: TextStyle(color: Colors.white70, fontSize: 9)),
          const SizedBox(height: 3),
          Container(
            width: 12,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6200EA), // extreme purple
                  Color(0xFFFF1744), // red
                  Color(0xFFFF6D00), // orange
                  Color(0xFFFFEA00), // yellow
                  Color(0xFF00E676), // green
                  Color(0xFF00E5FF), // cyan (low)
                ],
              ),
            ),
          ),
          const SizedBox(height: 3),
          const Text('Thấp',
              style: TextStyle(color: Colors.white70, fontSize: 9)),
          const SizedBox(height: 4),
          const Text('Nguy\ncơ',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
