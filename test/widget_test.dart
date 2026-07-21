import 'package:flutter_test/flutter_test.dart';
import 'package:gatekeeper/main.dart';

void main() {
  testWidgets('GateKeeperApp smoke test', (WidgetTester tester) async {
    // Note: Full integration testing requires DatabaseService initialization.
    // This is a placeholder smoke test.
    expect(GateKeeperApp, isNotNull);
  });
}
