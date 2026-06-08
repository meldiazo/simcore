import 'package:flutter/material.dart';

class FormErrorSummary extends StatelessWidget {
  const FormErrorSummary({super.key, required this.errors});

  final Map<String, String> errors;

  @override
  Widget build(BuildContext context) {
    if (errors.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: errors.entries
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '• ${e.key}: ${e.value}',
                    style: const TextStyle(
                        color: Color(0xFFEF4444), fontSize: 13),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
