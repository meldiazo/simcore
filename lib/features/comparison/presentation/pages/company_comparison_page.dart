import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/comparison/presentation/providers/comparison_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/loading_state.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/api_error_state.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:simcore_frontend/features/simulation/scenario/presentation/providers/scenario_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/company.dart';
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart' hide activeScenarioProvider;
import 'package:simcore_frontend/core/domain/simcore_enums.dart';

class CompanyComparisonPage extends ConsumerStatefulWidget {
  const CompanyComparisonPage({super.key});

  @override
  ConsumerState<CompanyComparisonPage> createState() => _CompanyComparisonPageState();
}

class _CompanyComparisonPageState extends ConsumerState<CompanyComparisonPage> {
  int _activeTab = 0;
  int? _selectedCompanyAId;
  int? _selectedCompanyBId;

  Widget _buildComparisonContent(
    BuildContext context,
    AsyncValue<Map<String, dynamic>> comparisonAsync,
    String selectedScenario,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScenarioSelector(selected: selectedScenario),
        const SizedBox(height: 20),
        comparisonAsync.when(
          loading: () => const LoadingState(message: 'Cargando comparación...'),
          error: (e, _) => ApiErrorState(
            title: 'No se pudo cargar la comparación',
            message: e.toString(),
            onRetry: () => ref.invalidate(courseComparisonProvider),
          ),
          data: (data) {
            final companies = (data['companies'] as List? ?? [])
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
            if (companies.isEmpty) {
              return const _EmptyComparison();
            }
            return _ComparisonTable(companies: companies);
          },
        ),
      ],
    );
  }

  Widget _buildCaraACaraContent(
    int courseId,
    AsyncValue<Map<String, dynamic>> comparisonAsync,
  ) {
    final companiesAsync = ref.watch(companiesByCourseProvider(courseId));

    return companiesAsync.when(
      loading: () => const LoadingState(message: 'Cargando datos cualitativos...'),
      error: (e, _) => ApiErrorState(
        title: 'Error al cargar empresas',
        message: e.toString(),
        onRetry: () => ref.invalidate(companiesByCourseProvider(courseId)),
      ),
      data: (companies) {
        if (companies.isEmpty) {
          return const GlassPanel(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No hay empresas registradas en este curso.'),
              ),
            ),
          );
        }

        // Auto-seleccionar por defecto
        if (_selectedCompanyAId == null && companies.isNotEmpty) {
          _selectedCompanyAId = companies[0].id;
        }
        if (_selectedCompanyBId == null && companies.length > 1) {
          _selectedCompanyBId = companies[1].id;
        }

        final companyA = companies.firstWhere((c) => c.id == _selectedCompanyAId, orElse: () => companies[0]);
        final companyB = companies.firstWhere((c) => c.id == _selectedCompanyBId, orElse: () => companies.length > 1 ? companies[1] : companies[0]);

        // Extraer métricas cuantitativas
        final comparisonData = comparisonAsync.valueOrNull ?? {'companies': []};
        final qCompanies = (comparisonData['companies'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        final qA = qCompanies.firstWhere((c) => c['companyId'] == companyA.id, orElse: () => <String, dynamic>{});
        final qB = qCompanies.firstWhere((c) => c['companyId'] == companyB.id, orElse: () => <String, dynamic>{});

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controles de selección de empresas
            GlassPanel(
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedCompanyAId,
                      decoration: const InputDecoration(
                        labelText: 'Empresa A',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: companies.map((c) {
                        return DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedCompanyAId = val);
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('VS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: SimcoreColors.accent)),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedCompanyBId,
                      decoration: const InputDecoration(
                        labelText: 'Empresa B',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: companies.map((c) {
                        return DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedCompanyBId = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Rejilla comparativa lado a lado
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildCompanyComparisonColumn(
                          company: companyA,
                          qData: qA,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                          ),
                          accentColor: const Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildCompanyComparisonColumn(
                          company: companyB,
                          qData: qB,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEC4899), Color(0xFFD946EF)],
                          ),
                          accentColor: const Color(0xFFEC4899),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildCompanyComparisonColumn(
                        company: companyA,
                        qData: qA,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                        ),
                        accentColor: const Color(0xFF6366F1),
                      ),
                      const SizedBox(height: 20),
                      _buildCompanyComparisonColumn(
                        company: companyB,
                        qData: qB,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEC4899), Color(0xFFD946EF)],
                        ),
                        accentColor: const Color(0xFFEC4899),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompanyComparisonColumn({
    required Company company,
    required Map<String, dynamic> qData,
    required Gradient gradient,
    required Color accentColor,
  }) {
    final van = qData['van'] as num?;
    final tir = qData['tir'] as num?;
    final pri = qData['priMonths'] as num?;
    final margin = qData['netMarginPct'] as num?;
    final totalRev = qData['totalRevenue'] as num?;
    final netInc = qData['netIncome'] as num?;
    final roi = qData['roiPct'] as num?;
    final isViable = qData['viable'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Encabezado de la empresa
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  company.simulationType.label,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                company.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Sector: ${company.sector} • Industria: ${company.industry}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Datos Cualitativos
        _buildComparisonDetailCard(
          title: 'Supuestos del Negocio',
          icon: Icons.lightbulb_outline_rounded,
          accentColor: accentColor,
          children: [
            _buildComparisonField('Misión', company.mission.isNotEmpty ? company.mission : 'No declarada'),
            _buildComparisonField('Visión', company.vision.isNotEmpty ? company.vision : 'No declarada'),
            _buildComparisonField('Descripción', company.description.isNotEmpty ? company.description : 'No declarada'),
          ],
        ),
        const SizedBox(height: 16),
        // Resultados Cuantitativos
        _buildComparisonDetailCard(
          title: 'Desempeño y Métricas',
          icon: Icons.analytics_outlined,
          accentColor: accentColor,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Ingresos Totales',
                    totalRev != null ? '\$${totalRev.toStringAsFixed(0)}' : '-',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    'Utilidad Neta',
                    netInc != null ? '\$${netInc.toStringAsFixed(0)}' : '-',
                    color: netInc != null && netInc < 0 ? SimcoreColors.danger : SimcoreColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'VAN (NPV)',
                    van != null ? '\$${van.toStringAsFixed(0)}' : '-',
                    color: van != null && van < 0 ? SimcoreColors.danger : SimcoreColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    'TIR (IRR)',
                    tir != null ? '${(tir * 100).toStringAsFixed(1)}%' : '-',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'ROI',
                    roi != null ? '${(roi * 100).toStringAsFixed(1)}%' : '-',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    'M. Neto',
                    margin != null ? '${(margin * 100).toStringAsFixed(1)}%' : '-',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'PRI (Payback)',
                    pri != null ? '$pri meses' : '-',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isViable ? SimcoreColors.successSoft : SimcoreColors.dangerSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        isViable ? 'PROYECTO VIABLE' : 'NO VIABLE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isViable ? SimcoreColors.success : SimcoreColors.danger,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonDetailCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SimcoreColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: SimcoreColors.textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildComparisonField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SimcoreColors.textTertiary),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(fontSize: 12, color: SimcoreColors.textPrimary, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SimcoreColors.muted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: SimcoreColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? SimcoreColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comparisonAsync = ref.watch(courseComparisonProvider);
    final selectedScenario = ref.watch(selectedScenarioTypeProvider);
    final user = ref.watch(authNotifierProvider).user;

    final ctx = ref.watch(simulationContextNotifierProvider).context;
    final courseId = ctx?.courseId ?? 0;

    Widget body;
    if (user != null && user.isEstudiante) {
      final activeScenarioAsync = ref.watch(activeScenarioProvider);
      body = activeScenarioAsync.when(
        loading: () => const LoadingState(message: 'Verificando visibilidad...'),
        error: (e, _) => ApiErrorState(
          title: 'Error de verificación',
          message: e.toString(),
          onRetry: () => ref.invalidate(activeScenarioProvider),
        ),
        data: (activeScenario) {
          if (activeScenario == null || !activeScenario.groupsCanSeeEachOther) {
            return GlassPanel(
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_off_rounded, size: 48, color: SimcoreColors.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'Comparación de Grupos Desactivada',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: SimcoreColors.textPrimary),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'El docente ha configurado este escenario para no permitir la comparación de resultados entre grupos.',
                        style: TextStyle(color: SimcoreColors.textSecondary, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Column(
            children: [
              TabBar(
                onTap: (index) => setState(() => _activeTab = index),
                labelColor: SimcoreColors.accent,
                unselectedLabelColor: SimcoreColors.textSecondary,
                indicatorColor: SimcoreColors.accent,
                tabs: const [
                  Tab(icon: Icon(Icons.table_chart_rounded), text: 'Ranking Financiero'),
                  Tab(icon: Icon(Icons.compare_rounded), text: 'Cara a Cara'),
                ],
              ),
              const SizedBox(height: 20),
              _activeTab == 0
                  ? _buildComparisonContent(context, comparisonAsync, selectedScenario)
                  : _buildCaraACaraContent(courseId, comparisonAsync),
            ],
          );
        },
      );
    } else {
      body = Column(
        children: [
          TabBar(
            onTap: (index) => setState(() => _activeTab = index),
            labelColor: SimcoreColors.accent,
            unselectedLabelColor: SimcoreColors.textSecondary,
            indicatorColor: SimcoreColors.accent,
            tabs: const [
              Tab(icon: Icon(Icons.table_chart_rounded), text: 'Ranking Financiero'),
              Tab(icon: Icon(Icons.compare_rounded), text: 'Cara a Cara'),
            ],
          ),
          const SizedBox(height: 20),
          _activeTab == 0
              ? _buildComparisonContent(context, comparisonAsync, selectedScenario)
              : _buildCaraACaraContent(courseId, comparisonAsync),
        ],
      );
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageIntro(
            title: 'Comparación Académica',
            subtitle: 'Métricas cualitativas y financieras comparadas entre empresas.',
          ),
          const SizedBox(height: 20),
          body,
        ],
      ),
    );
  }
}

class _ScenarioSelector extends ConsumerWidget {
  const _ScenarioSelector({required this.selected});

  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const options = ['PROBABLE', 'OPTIMISTIC', 'PESSIMISTIC'];
    const labels = {
      'PROBABLE': 'Probable',
      'OPTIMISTIC': 'Optimista',
      'PESSIMISTIC': 'Pesimista',
    };
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final active = opt == selected;
        return ChoiceChip(
          label: Text(labels[opt] ?? opt),
          selected: active,
          selectedColor: SimcoreColors.accent,
          labelStyle: TextStyle(
            color: active ? Colors.white : SimcoreColors.textSecondary,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
          onSelected: (_) {
            ref.read(selectedScenarioTypeProvider.notifier).state = opt;
          },
        );
      }).toList(),
    );
  }
}

class _EmptyComparison extends StatelessWidget {
  const _EmptyComparison();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: SimcoreColors.muted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  size: 40,
                  color: SimcoreColors.textTertiary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sin Datos de Comparación',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: SimcoreColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Aún no hay empresas creadas o simuladas en este curso para realizar la comparativa académica.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: SimcoreColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({required this.companies});

  final List<Map<String, dynamic>> companies;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            children: companies.map((c) => _CompanyCard(data: c)).toList(),
          );
        }
        return GlassPanel(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 28,
              horizontalMargin: 24,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 64,
              headingRowHeight: 56,
              dividerThickness: 0.5,
              headingRowColor: WidgetStateProperty.all(SimcoreColors.muted.withValues(alpha: 0.35)),
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: SimcoreColors.textPrimary,
              ),
              columns: const [
                DataColumn(label: Text('Empresa')),
                DataColumn(label: Text('Grupo')),
                DataColumn(label: Text('VAN'), numeric: true),
                DataColumn(label: Text('TIR'), numeric: true),
                DataColumn(label: Text('PRI (m)'), numeric: true),
                DataColumn(label: Text('M. Neto'), numeric: true),
                DataColumn(label: Text('Incoher. Altas'), numeric: true),
                DataColumn(label: Text('Módulos'), numeric: true),
              ],
              rows: companies.map((c) {
                final van = c['van'] as num?;
                final tir = c['tir'] as num?;
                final pri = c['priMonths'] as num?;
                final margin = c['netMarginPct'] as num?;
                final incoherences = c['incoherencesHigh'] as num? ?? 0;
                final completed = c['completedModules'] as num? ?? 0;

                return DataRow(cells: [
                  DataCell(Text(
                    (c['companyName'] ?? '-').toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )),
                  DataCell(Text((c['groupName'] ?? '-').toString())),
                  DataCell(Text(van != null ? van.toStringAsFixed(0) : '-')),
                  DataCell(Text(tir != null
                      ? '${(tir * 100).toStringAsFixed(1)}%'
                      : '-')),
                  DataCell(Text(pri != null ? pri.toString() : '-')),
                  DataCell(Text(margin != null
                      ? '${(margin * 100).toStringAsFixed(1)}%'
                      : '-')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: incoherences > 0
                            ? SimcoreColors.dangerSoft
                            : SimcoreColors.successSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        incoherences.toString(),
                        style: TextStyle(
                          color: incoherences > 0
                              ? SimcoreColors.danger
                              : SimcoreColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(completed.toString())),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final van = data['van'] as num?;
    final tir = data['tir'] as num?;
    final pri = data['priMonths'] as num?;
    final margin = data['netMarginPct'] as num?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (data['companyName'] ?? '-').toString(),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Text(
              (data['groupName'] ?? '-').toString(),
              style: const TextStyle(color: SimcoreColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                MobileInfoRow(
                  label: 'VAN',
                  value: van != null ? van.toStringAsFixed(0) : '-',
                ),
                MobileInfoRow(
                  label: 'TIR',
                  value: tir != null
                      ? '${(tir * 100).toStringAsFixed(1)}%'
                      : '-',
                ),
                MobileInfoRow(
                  label: 'PRI (meses)',
                  value: pri != null ? pri.toString() : '-',
                ),
                MobileInfoRow(
                  label: 'M. Neto',
                  value: margin != null
                      ? '${(margin * 100).toStringAsFixed(1)}%'
                      : '-',
                ),
                MobileInfoRow(
                  label: 'Incoher. Altas',
                  value: (data['incoherencesHigh'] ?? 0).toString(),
                ),
                MobileInfoRow(
                  label: 'Módulos',
                  value: (data['completedModules'] ?? 0).toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MobileInfoRow extends StatelessWidget {
  const MobileInfoRow({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SimcoreColors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: SimcoreColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SimcoreColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
