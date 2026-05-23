import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_view/panel_view.dart';

void main() {
  testWidgets('renders open panels from registered builders', (tester) async {
    final manager = PanelManagerService()
      ..registerPanel(
        const PanelConfig(
          id: 'notes',
          initialPosition: Offset.zero,
          initialWidth: 300,
          initialHeight: 200,
        ),
      )
      ..registerPanelBuilder(
        'notes',
        PanelContentBuilder(
          title: 'Notes',
          builder: (_) => const Text('Notes content'),
        ),
      )
      ..openPanel('notes');

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            const SizedBox.expand(),
            GlobalPanelOverlay(panelManager: manager),
          ],
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Notes content'), findsOneWidget);

    manager.dispose();
  });

  testWidgets('hides default close button for non-dismissible panels', (
    tester,
  ) async {
    final manager = PanelManagerService()
      ..registerPanel(
        const PanelConfig(
          id: 'locked',
          initialPosition: Offset.zero,
          initialWidth: 300,
          initialHeight: 200,
          isDismissible: false,
        ),
      )
      ..registerPanelBuilder(
        'locked',
        PanelContentBuilder(
          title: 'Locked',
          builder: (_) => const Text('Locked content'),
        ),
      )
      ..openPanel('locked');

    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            const SizedBox.expand(),
            GlobalPanelOverlay(panelManager: manager),
          ],
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Locked'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);

    manager.dispose();
  });
}
