import 'package:flutter/material.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import '../../data/models/financing_option_model.dart';

class AddFinancingModal extends StatefulWidget {
  final Function(FinancingType type, double amount, double interestRate, int termInMonths) onSave;

  const AddFinancingModal({super.key, required this.onSave});

  @override
  State<AddFinancingModal> createState() => _AddFinancingModalState();
}

class _AddFinancingModalState extends State<AddFinancingModal> {
  final _formKey = GlobalKey<FormState>();
  FinancingType _selectedType = FinancingType.BANK_LOAN;
  double _amount = 0;
  double _interestRate = 0;
  int _termInMonths = 12;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Simular Estructura de Fondeo', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Fuente de financiamiento:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<FinancingType>(
                value: _selectedType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: FinancingType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.displayName));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 16),
              const Text('Monto a fondear (\$):', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
                validator: (value) => (value == null || double.tryParse(value) == null || double.parse(value) <= 0) ? 'Monto inválido' : null,
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Costo (TEA %):', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  decoration: const InputDecoration(
    border: OutlineInputBorder(),
    suffixIcon: Icon(Icons.percent, size: 18),
  ),
  validator: (value) {
    final rate = double.tryParse(value ?? '');
    if (rate == null) return 'Inválido';
    if (rate < 0 || rate > 100) return 'Debe estar entre 0 y 100';
    return null;
  },
  onSaved: (value) => _interestRate = double.parse(value!),
),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Plazo (Meses):', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_month, size: 18)),
                          validator: (value) => (value == null || int.tryParse(value) == null || int.parse(value) <= 0) ? 'Inválido' : null,
                          onSaved: (value) => _termInMonths = int.parse(value!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: SimcoreColors.textSecondary)),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onSave(_selectedType, _amount, _interestRate, _termInMonths);
              Navigator.of(context).pop();
            }
          },
          style: FilledButton.styleFrom(backgroundColor: SimcoreColors.accent),
          child: const Text('Agregar Opción'),
        ),
      ],
    );
  }
}