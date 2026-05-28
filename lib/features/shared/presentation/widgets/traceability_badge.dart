import 'package:flutter/material.dart';

class TraceabilityBadge extends StatelessWidget {
  const TraceabilityBadge({
    super.key,
    required this.source,
    required this.label,
  });

  final String source;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.link_rounded, size: 12, color: Color(0xFF3B82F6)),
          const SizedBox(width: 4),
          Text(
            '$source: $label',
            style: const TextStyle(fontSize: 11, color: Color(0xFF3B82F6)),
          ),
        ],
      ),
    );
  }
}
