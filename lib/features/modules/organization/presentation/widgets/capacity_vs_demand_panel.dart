import 'package:flutter/material.dart';
import '../../data/models/organization_summary_model.dart';

class CapacityVsDemandPanel extends StatelessWidget {
  final OrganizationSummaryModel summary;

  const CapacityVsDemandPanel({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final double capacity = summary.totalCapacity;
    final double demand = summary.projectedDemand;
    
    // Aquí está la tensión pedagógica: ¿la capacidad cubre la demanda?
    final bool isDeficit = capacity < demand;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDeficit ? Colors.red.shade300 : Colors.green.shade300,
          width: 1.5,
        ),
      ),
      color: isDeficit ? Colors.red.shade50 : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análisis de Capacidad Operativa vs. Mercado',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDeficit ? Colors.red.shade900 : Colors.green.shade900,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MetricColumn(
                  label: 'Demanda Proyectada (Módulo Mercado)', 
                  value: demand.toStringAsFixed(0),
                  color: Colors.blue.shade800,
                ),
                Text('vs', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                _MetricColumn(
                  label: 'Capacidad Instalada (Estructura Actual)', 
                  value: capacity.toStringAsFixed(0),
                  color: isDeficit ? Colors.red.shade800 : Colors.green.shade800,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isDeficit)
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Peligro Estratégico! Tu estructura organizativa actual no tiene el personal suficiente para cubrir las ventas que proyectaste en Mercado. Necesitas contratar más personal operativo o reducir tus metas de ventas.',
                      style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Capacidad Operativa Suficiente. Tu estructura organizativa actual puede soportar la demanda comercial proyectada.',
                      style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricColumn({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}