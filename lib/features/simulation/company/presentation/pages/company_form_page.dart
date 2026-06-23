import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/company.dart';
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart';
import 'package:simcore_frontend/features/academic/presentation/providers/academic_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';

class CompanyFormPage extends ConsumerStatefulWidget {
  const CompanyFormPage({super.key, required this.groupId});

  final int groupId;

  @override
  ConsumerState<CompanyFormPage> createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends ConsumerState<CompanyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _industryCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _missionCtrl = TextEditingController();
  final _visionCtrl = TextEditingController();
  CompanySector _sector = CompanySector.services;
  Company? _createdCompany;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _industryCtrl.dispose();
    _descriptionCtrl.dispose();
    _missionCtrl.dispose();
    _visionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(companyFormNotifierProvider.notifier);
    final company = await notifier.createCompany(
      groupId: widget.groupId,
      name: _nameCtrl.text.trim(),
      sector: _sector.toApi(),
      industry: _industryCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      mission: _missionCtrl.text.trim(),
      vision: _visionCtrl.text.trim(),
    );
    if (company != null && mounted) {
      setState(() => _createdCompany = company);
    }
  }

  Future<void> _activate() async {
  if (_createdCompany == null) return;

  final notifier = ref.read(companyFormNotifierProvider.notifier);
  final activated = await notifier.activateCompany(
    companyId: _createdCompany!.id,
  );

  if (activated != null) {
    await ref.read(groupNotifierProvider.notifier).linkCompany(
          groupId: widget.groupId,
          companyId: activated.id,
        );

    if (mounted) {
      setState(() => _createdCompany = activated);
      showSimcoreSuccessDialog(
        context: context,
        title: '¡Empresa Activada!',
        message: 'La empresa ha sido activada y vinculada al grupo exitosamente.',
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(companyFormNotifierProvider);
    final isLoading = formState is AsyncLoading;
    final error = formState is AsyncError ? formState.error.toString() : null;

    return Scaffold(
      backgroundColor: SimcoreColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Crear empresa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: GlassPanel(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Detalles de la Empresa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: SimcoreColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Completa la información para constituir la empresa simulada.',
                      style: TextStyle(
                        fontSize: 14,
                        color: SimcoreColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: SimcoreColors.dangerSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(error, style: const TextStyle(color: SimcoreColors.danger)),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildField('Nombre de empresa', _nameCtrl, required: true),
                    const SizedBox(height: 16),
                    _buildSectorDropdown(),
                    const SizedBox(height: 16),
                    _buildField('Industria', _industryCtrl, required: true),
                    const SizedBox(height: 16),
                    _buildField(
                      'Descripción',
                      _descriptionCtrl,
                      required: true,
                      minLength: 50,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildField('Misión', _missionCtrl, required: true, maxLines: 2),
                    const SizedBox(height: 16),
                    _buildField('Visión', _visionCtrl, required: true, maxLines: 2),
                    const SizedBox(height: 24),
                    if (_createdCompany == null)
                      FilledButton(
                        onPressed: isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Crear empresa', style: TextStyle(fontSize: 16)),
                      ),
                    if (_createdCompany != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: SimcoreColors.successSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Empresa creada: ${_createdCompany!.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: SimcoreColors.success,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Estado: ${_createdCompany!.status.label}'),
                          ],
                        ),
                      ),
                      if (_createdCompany!.status == CompanyStatus.draft) ...[
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: isLoading ? null : _activate,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Activar empresa'),
                          style: FilledButton.styleFrom(
                            backgroundColor: SimcoreColors.success,
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    bool required = false,
    int? minLength,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: SimcoreColors.textSecondary),
        floatingLabelStyle: const TextStyle(color: SimcoreColors.accent, fontWeight: FontWeight.w600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SimcoreColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SimcoreColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SimcoreColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SimcoreColors.danger, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: const TextStyle(color: SimcoreColors.textPrimary),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'Campo requerido';
        }
        if (minLength != null && (value?.trim().length ?? 0) < minLength) {
          return 'Mínimo $minLength caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildSectorDropdown() {
    return DropdownButtonFormField<CompanySector>(
      initialValue: _sector,
      decoration: InputDecoration(
        labelText: 'Sector',
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: SimcoreColors.textSecondary),
        floatingLabelStyle: const TextStyle(color: SimcoreColors.accent, fontWeight: FontWeight.w600),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SimcoreColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SimcoreColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dropdownColor: Colors.white,
      style: const TextStyle(color: SimcoreColors.textPrimary),
      items: CompanySector.values
          .map((s) => DropdownMenuItem(
                value: s,
                child: Text(s.label, style: const TextStyle(color: SimcoreColors.textPrimary)),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) setState(() => _sector = value);
      },
    );
  }
}
