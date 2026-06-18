import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/ai/data/models/ai_suggestion_model.dart';

class AiSuggestionCard extends StatelessWidget {
  const AiSuggestionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.suggestionAsync,
  });

  final String title;
  final IconData icon;
  final AsyncValue<AiSuggestionModel?> suggestionAsync;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SimcoreColors.muted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SimcoreColors.border),
      ),
      child: suggestionAsync.when(
        loading: () => const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Generando apoyo del asistente...')),
          ],
        ),
        error: (e, _) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: SimcoreColors.warning,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No se pudo cargar esta sugerencia. $e',
                style: const TextStyle(
                  color: SimcoreColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        data: (suggestion) {
          final content = suggestion?.content.trim() ?? '';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: SimcoreColors.accent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (suggestion?.aiGenerated == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: SimcoreColors.accentSoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'IA',
                        style: TextStyle(
                          color: SimcoreColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                content.isEmpty ? 'Sin sugerencia disponible.' : content,
                style: const TextStyle(
                  color: SimcoreColors.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
