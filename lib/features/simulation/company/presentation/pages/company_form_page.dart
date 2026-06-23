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
  SimulationType _simulationType = SimulationType.startup;
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
      simulationType: _simulationType,
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
                    _buildSimulationTypeSelector(),
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

  Widget _buildSimulationTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modalidad de Simulación',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: SimcoreColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 400;
            return isWide
                ? Row(
                    children: SimulationType.values
                        .map((type) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: _buildTypeCard(type),
                              ),
                            ))
                        .toList(),
                  )
                : Column(
                    children: SimulationType.values
                        .map((type) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: _buildTypeCard(type),
                            ))
                        .toList(),
                  );
          },
        ),
      ],
    );
  }

  Widget _buildTypeCard(SimulationType type) {
    final isSelected = _simulationType == type;

    final IconData icon;
    final String title;
    final String description;
    final List<Color> gradientColors;

    switch (type) {
      case SimulationType.startup:
        icon = Icons.rocket_launch_rounded;
        title = 'Startup';
        description = 'Creación y consolidación de una nueva empresa.';
        gradientColors = [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
        break;
      case SimulationType.productLaunch:
        icon = Icons.new_releases_rounded;
        title = 'Lanzamiento';
        description = 'Introducción de un nuevo producto.';
        gradientColors = [const Color(0xFFEC4899), const Color(0xFFD946EF)];
        break;
      case SimulationType.competition:
        icon = Icons.leaderboard_rounded;
        title = 'Competencia';
        description = 'Batalla directa por cuota de mercado.';
        gradientColors = [const Color(0xFFF59E0B), const Color(0xFFD97706)];
        break;
    }

    return InkWell(
      onTap: () {
        setState(() => _simulationType = type);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? gradientColors[0] : SimcoreColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
          gradient: isSelected
              ? LinearGradient(
                  colors: gradientColors.map((c) => c.withOpacity(0.12)).toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected ? gradientColors[0] : SimcoreColors.border.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isSelected ? Colors.white : SimcoreColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? gradientColors[0] : SimcoreColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? SimcoreColors.textPrimary : SimcoreColors.textSecondary,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
