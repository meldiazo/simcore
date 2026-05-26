import 'package:simcore_frontend/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('workspace page renders correctly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Workspace SIMCORE'), findsOneWidget);
    expect(find.text('Centro de Decisiones'), findsOneWidget);
  });
}
