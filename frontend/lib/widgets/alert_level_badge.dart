import 'package:flutter/material.dart';
import '../config/constants.dart';

class AlertLevelBadge extends StatelessWidget {
  final String level;
  final bool large;

  const AlertLevelBadge({super.key, required this.level, this.large = false});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;
    switch (level) {
      case 'red':
        color = kColorRed;
        label = 'NGUY HIỂM';
        icon = Icons.warning_rounded;
        break;
      case 'yellow':
        color = kColorYellow;
        label = 'CHÚ Ý';
        icon = Icons.info_rounded;
        break;
      default:
        color = kColorGreen;
        label = 'AN TOÀN';
        icon = Icons.check_circle_rounded;
    }
    final size = large ? 18.0 : 13.0;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 16 : 8, vertical: large ? 8 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: size + 2),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: size, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
