import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import '../../data/models/investment_item_model.dart';

class AddInvestmentModal extends StatefulWidget {
  final Function(InvestmentType type, String description, double amount) onSave;

  const AddInvestmentModal({super.key, required this.onSave});

  @override
  State<AddInvestmentModal> createState() => _AddInvestmentModalState();
}

class _AddInvestmentModalState extends State<AddInvestmentModal> {
  final _formKey = GlobalKey<FormState>();
  InvestmentType _selectedType = InvestmentType.FIXED_ASSET;
  String _description = '';
  double _amount = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar Requerimiento de Capital',
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Categoría de la inversión:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<InvestmentType>(
                value: _selectedType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: InvestmentType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 16),
              const Text('Descripción detallada:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ej. Maquinaria de producción, Licencias...',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Requerido' : null,
                onSaved: (value) => _description = value!.trim(),
              ),
              const SizedBox(height: 16),
              const Text('Monto Estimado (\$):',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  final num = double.tryParse(value);
                  if (num == null || num <= 0) return 'Debe ser mayor a 0';
                  return null;
                },
                onSaved: (value) => _amount = double.parse(value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar',
              style: TextStyle(color: SimcoreColors.textSecondary)),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onSave(_selectedType, _description, _amount);
              Navigator.of(context).pop();
            }
          },
          style: FilledButton.styleFrom(backgroundColor: SimcoreColors.accent),
          child: const Text('Registrar Inversión'),
        ),
      ],
    );
  }
}
