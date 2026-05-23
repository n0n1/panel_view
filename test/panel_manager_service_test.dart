import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_view/panel_view.dart';

void main() {
  group('PanelManagerService', () {
    late PanelManagerService manager;

    setUp(() {
      manager = PanelManagerService();
    });

    tearDown(() {
      manager.dispose();
    });

    test('registers, opens, closes, toggles, and unregisters panels', () {
      const config = PanelConfig(id: 'panel');

      manager.registerPanel(config);
      expect(manager.isPanelRegistered('panel'), isTrue);
      expect(manager.getPanel('panel')?.isOpen, isFalse);

      manager.openPanel('panel');
      expect(manager.getPanel('panel')?.isOpen, isTrue);

      manager.closePanel('panel');
      expect(manager.getPanel('panel')?.isOpen, isFalse);

      manager.togglePanel('panel');
      expect(manager.getPanel('panel')?.isOpen, isTrue);

      manager.unregisterPanel('panel');
      expect(manager.isPanelRegistered('panel'), isFalse);
    });

    test('tracks z-index and focused panel', () {
      manager.registerPanel(const PanelConfig(id: 'first'));
      manager.registerPanel(const PanelConfig(id: 'second'));

      manager.openPanel('first');
      manager.openPanel('second');

      expect(manager.getFocusedPanel()?.id, 'second');

      manager.bringToFront('first');
      expect(manager.getFocusedPanel()?.id, 'first');
      expect(
        manager.getPanel('first')!.zIndex,
        greaterThan(manager.getPanel('second')!.zIndex),
      );
    });

    test('cycles focus between open panels', () {
      manager.registerPanel(const PanelConfig(id: 'first'));
      manager.registerPanel(const PanelConfig(id: 'second'));
      manager.registerPanel(const PanelConfig(id: 'third'));

      manager.openPanel('first');
      manager.openPanel('second');
      manager.openPanel('third');

      expect(manager.getFocusedPanel()?.id, 'third');

      manager.focusNextPanel();
      expect(manager.getFocusedPanel()?.id, 'first');

      manager.focusPreviousPanel();
      expect(manager.getFocusedPanel()?.id, 'third');
    });

    test('updates position and size', () {
      manager.registerPanel(const PanelConfig(id: 'panel'));

      manager.updatePosition('panel', const Offset(12, 24));
      manager.updateSize('panel', const Size(300, 200));

      final panel = manager.getPanel('panel');
      expect(panel?.position, const Offset(12, 24));
      expect(panel?.size, const Size(300, 200));
    });
  });
}
