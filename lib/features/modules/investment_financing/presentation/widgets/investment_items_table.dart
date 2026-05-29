import 'package:flutter/material.dart';
import '../../data/models/investment_item_model.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart'; 

class InvestmentItemsTable extends StatelessWidget {
  final List<InvestmentItemModel> items;

  const InvestmentItemsTable({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'Aún no has registrado requerimientos de inversión. Agrega tus activos, capital de trabajo o gastos pre-operativos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: SimcoreColors.textSecondary, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    // Calculamos el total para generar conciencia financiera en el estudiante
    final totalInvestment = items.fold(0.0, (sum, item) => sum + item.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DataTable(
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
          columns: const [
            DataColumn(label: Text('Tipo de Inversión')),
            DataColumn(label: Text('Descripción')),
            DataColumn(label: Text('Monto Requerido'), numeric: true),
          ],
          rows: items.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item.type.displayName)),
                DataCell(Text(item.description)),
                DataCell(Text('\$${item.amount.toStringAsFixed(2)}')),
              ],
            );
          }).toList(),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Inversión Total Requerida: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${totalInvestment.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.w900, 
                  color: SimcoreColors.accent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}