import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum DemoModeBannerTone {
  mock,
  warning,
}

class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({
    super.key,
    required this.visible,
    required this.message,
    this.tone = DemoModeBannerTone.mock,
  });

  final bool visible;
  final String message;
  final DemoModeBannerTone tone;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final isWarning = tone == DemoModeBannerTone.warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFFF7E6) : const Color(0xFFEFF6FF),
        border: Border(
          bottom: BorderSide(
            color:
                isWarning ? const Color(0xFFFFD591) : const Color(0xFFBBD7FF),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isWarning ? Icons.warning_amber_rounded : Icons.science_outlined,
            size: 18,
            color: isWarning ? const Color(0xFFB76E00) : SimcoreColors.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: isWarning
                    ? const Color(0xFF7A4D00)
                    : SimcoreColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
