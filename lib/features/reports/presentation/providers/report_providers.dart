import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

final reportScenarioTypeProvider =
    StateProvider.autoDispose<String>((ref) => 'PROBABLE');

final narrativeReportProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final ctx = ref.watch(simulationContextNotifierProvider).context;
  if (ctx == null) return {};
  final scenarioType = ref.watch(reportScenarioTypeProvider);
  return ref.watch(reportsDataSourceProvider).getCompanyReport(
        companyId: ctx.companyId,
        scenarioType: scenarioType,
      );
});

// ── Export Notifier ───────────────────────────────────────────────────────────

class ReportExportNotifier extends StateNotifier<AsyncValue<String?>> {
  ReportExportNotifier(this._ds, this._ref)
      : super(const AsyncValue.data(null));

  final ReportsRemoteDataSource _ds;
  final Ref _ref;

  Future<void> downloadPdf(int? companyId) async {
    final id = companyId ??
        _ref.read(simulationContextNotifierProvider).context?.companyId;
    if (id == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ds.exportCompanyPdf(companyId: id);
      return 'PDF generado correctamente.';
    });
  }

  Future<void> downloadCsv(int? courseId) async {
    final id = courseId ??
        _ref.read(simulationContextNotifierProvider).context?.courseId;
    if (id == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _ds.exportCourseCsv(courseId: id);
      return 'CSV del curso generado correctamente.';
    });
  }
}

final reportExportNotifierProvider =
    StateNotifierProvider.autoDispose<ReportExportNotifier, AsyncValue<String?>>(
  (ref) => ReportExportNotifier(
    ref.watch(reportsDataSourceProvider),
    ref,
  ),
);
