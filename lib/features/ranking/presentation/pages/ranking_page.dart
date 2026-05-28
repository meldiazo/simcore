import 'package:flutter/material.dart';
import 'package:simcore_frontend/features/comparison/presentation/pages/company_comparison_page.dart';

/// Legacy page kept for router compatibility.
/// All content is now handled by [CompanyComparisonPage].
class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) => const CompanyComparisonPage();
}
