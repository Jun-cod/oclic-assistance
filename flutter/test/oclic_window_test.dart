import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_hbb/desktop/pages/oclic_assistance.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('A native active stream confirms the current peer despite an old UI state', () {
    expect(oclicActiveConnectionId(17, 1, [
      {'id': 17, 'authorized': true, 'disconnected': false},
    ]), 17);
  });

  test('A pending request or a different peer cannot inherit an active session', () {
    expect(oclicActiveConnectionId(17, 0, [
      {'id': 17, 'authorized': true},
    ]), isNull);
    expect(oclicActiveConnectionId(18, 1, [
      {'id': 17, 'authorized': true},
      {'id': 18, 'authorized': false},
    ]), isNull);
    expect(oclicActiveConnectionId(17, 1, [
      {'id': 17, 'authorized': true, 'disconnected': true},
    ]), isNull);
  });

  test('An authorized file channel works without video and cannot authorize another request', () {
    final clients = [
      {'id': 17, 'authorized': true, 'disconnected': false, 'is_file_transfer': true},
      {'id': 18, 'authorized': false, 'disconnected': false, 'is_file_transfer': true},
    ];
    expect(oclicActiveConnectionId(17, 0, clients), 17);
    expect(oclicActiveConnectionId(18, 1, clients), isNull);
    expect(oclicActiveConnectionId(17, 0, [
      {'id': 17, 'authorized': true, 'disconnected': true, 'is_file_transfer': true},
    ]), isNull);
  });

  testWidgets('The shared minimize control requests minimization without closing assistance', (tester) async {
    final calls = <String>[];
    var closed = false;
    const channel = MethodChannel('window_manager');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return null;
    });
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));
    await tester.pumpWidget(MaterialApp(home: OclicFrame(
      status: 'Prêt', onClose: () { closed = true; },
      actions: const SizedBox(), child: const Text('Contrôle de la fenêtre'),
    )));
    await tester.tap(find.byTooltip('Réduire'));
    await tester.pump();
    expect(calls, contains('minimize'));
    expect(calls, isNot(contains('close')));
    expect(calls, isNot(contains('destroy')));
    expect(closed, isFalse);
  });
}
