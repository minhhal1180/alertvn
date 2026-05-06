import 'package:flutter/material.dart';
import '../config/constants.dart';

class DisasterFilterBar extends StatelessWidget {
  final String? activeFilter;
  final ValueChanged<String?> onFilterChanged;

  const DisasterFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final types = ['storm', 'flood', 'landslide', 'tree_fall', 'heatwave'];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final type = types[i];
          final isActive = activeFilter == type;
          final color = kDisasterColors[type]!;
          return GestureDetector(
            onTap: () => onFilterChanged(isActive ? null : type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isActive ? color : Colors.grey.shade300, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(kDisasterIcons[type],
                      size: 15,
                      color: isActive ? Colors.white : color),
                  const SizedBox(width: 4),
                  Text(
                    kDisasterLabels[type]!,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade800,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
