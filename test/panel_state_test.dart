import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_view/panel_view.dart';

void main() {
  group('PanelState', () {
    test('creates initial state from config', () {
      const config = PanelConfig(
        id: 'panel',
        initialPosition: Offset(10, 20),
        initialWidth: 320,
        initialHeight: 240,
      );

      final state = PanelState.fromConfig(config);

      expect(state.id, 'panel');
      expect(state.position, const Offset(10, 20));
      expect(state.size, const Size(320, 240));
      expect(state.isOpen, isFalse);
      expect(state.zIndex, 0);
    });

    test('clamps resized panel to configured constraints', () {
      final state = PanelState.fromConfig(
        const PanelConfig(
          id: 'panel',
          minWidth: 200,
          maxWidth: 400,
          minHeight: 100,
          maxHeight: 300,
        ),
      );

      expect(state.resizedTo(const Size(100, 50)).size, const Size(200, 100));
      expect(state.resizedTo(const Size(600, 500)).size, const Size(400, 300));
      expect(state.resizedTo(const Size(320, 220)).size, const Size(320, 220));
    });
  });
}
