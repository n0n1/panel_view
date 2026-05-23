import 'dart:async';

import 'package:flutter/material.dart';

import 'package:panel_view/src/domain/entities/panel_config.dart';
import 'package:panel_view/src/domain/entities/panel_state.dart';
import 'package:panel_view/src/presentation/widgets/panel_content_builder.dart';

/// Global service for managing all panels in the application
/// Provides reactive state management for panels with z-index ordering,
/// position/size tracking, and keyboard navigation support
class PanelManagerService {
  final Map<String, PanelState> _panels = {};
  final Map<String, PanelContentBuilder> _panelBuilders = {};
  final StreamController<Map<String, PanelState>> _panelsController =
      StreamController<Map<String, PanelState>>.broadcast();

  int _nextZIndex = 1;

  /// Stream of all panel states
  Stream<Map<String, PanelState>> get panelsStream => _panelsController.stream;

  /// Current panel states
  Map<String, PanelState> get panels => Map.unmodifiable(_panels);

  /// Get panel state by ID
  PanelState? getPanel(String id) => _panels[id];

  /// Check if panel is registered
  bool isPanelRegistered(String id) => _panels.containsKey(id);

  /// Register a new panel
  void registerPanel(PanelConfig config) {
    if (_panels.containsKey(config.id)) {
      // Panel already registered, don't recreate
      return;
    }

    final state = PanelState.fromConfig(config);
    _panels[config.id] = state;
    _notifyListeners();
  }

  /// Unregister a panel
  void unregisterPanel(String id) {
    _panels.remove(id);
    _notifyListeners();
  }

  /// Open a panel (make it visible)
  void openPanel(String id) {
    final panel = _panels[id];
    if (panel == null) return;

    _panels[id] = panel.open().bringToFront(_nextZIndex++);
    _notifyListeners();
  }

  /// Close a panel (hide it)
  void closePanel(String id) {
    final panel = _panels[id];
    if (panel == null) return;

    _panels[id] = panel.close();
    _notifyListeners();
  }

  /// Toggle panel open/close
  void togglePanel(String id) {
    final panel = _panels[id];
    if (panel == null) return;

    if (panel.isOpen) {
      closePanel(id);
    } else {
      openPanel(id);
    }
  }

  /// Bring panel to front (highest z-index)
  void bringToFront(String id) {
    final panel = _panels[id];
    if (panel == null) return;

    _panels[id] = panel.bringToFront(_nextZIndex++);
    _notifyListeners();
  }

  /// Update panel position
  void updatePosition(String id, Offset position) {
    final panel = _panels[id];
    if (panel == null) return;

    _panels[id] = panel.movedTo(position);
    _notifyListeners();
  }

  /// Update panel size
  void updateSize(String id, Size size) {
    final panel = _panels[id];
    if (panel == null) return;

    _panels[id] = panel.resizedTo(size);
    _notifyListeners();
  }

  /// Toggle minimize state
  void toggleMinimize(String id) {
    final panel = _panels[id];
    if (panel == null) return;

    _panels[id] = panel.toggleMinimize();
    _notifyListeners();
  }

  /// Get list of open panels sorted by z-index (lowest to highest)
  List<PanelState> getOpenPanelsSorted() {
    return _panels.values.where((panel) => panel.isOpen).toList()
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
  }

  /// Get the currently focused panel (highest z-index among open panels)
  PanelState? getFocusedPanel() {
    final openPanels = getOpenPanelsSorted();
    return openPanels.isEmpty ? null : openPanels.last;
  }

  /// Focus next panel in cycle (for Cmd+P navigation)
  void focusNextPanel() {
    final openPanels = getOpenPanelsSorted();
    if (openPanels.isEmpty) return;

    if (openPanels.length == 1) {
      // Only one panel, just bring it to front
      bringToFront(openPanels.first.id);
      return;
    }

    // Get current focused panel
    final currentFocused = getFocusedPanel();
    if (currentFocused == null) return;

    // Find index of current focused
    final currentIndex = openPanels.indexWhere(
      (p) => p.id == currentFocused.id,
    );

    // Get next panel (cycle back to start if at end)
    final nextIndex = (currentIndex + 1) % openPanels.length;
    final nextPanel = openPanels[nextIndex];

    // Bring next panel to front
    bringToFront(nextPanel.id);
  }

  /// Focus previous panel in cycle (for Shift+Cmd+P navigation)
  void focusPreviousPanel() {
    final openPanels = getOpenPanelsSorted();
    if (openPanels.isEmpty) return;

    if (openPanels.length == 1) {
      bringToFront(openPanels.first.id);
      return;
    }

    final currentFocused = getFocusedPanel();
    if (currentFocused == null) return;

    final currentIndex = openPanels.indexWhere(
      (p) => p.id == currentFocused.id,
    );
    final prevIndex =
        (currentIndex - 1 + openPanels.length) % openPanels.length;
    final prevPanel = openPanels[prevIndex];

    bringToFront(prevPanel.id);
  }

  /// Close all open panels
  void closeAllPanels() {
    for (final id in _panels.keys) {
      final panel = _panels[id];
      if (panel != null && panel.isOpen) {
        _panels[id] = panel.close();
      }
    }
    _notifyListeners();
  }

  /// Register a panel builder dynamically
  void registerPanelBuilder(String id, PanelContentBuilder builder) {
    _panelBuilders[id] = builder;
  }

  /// Unregister panel builder
  void unregisterPanelBuilder(String id) {
    _panelBuilders.remove(id);
  }

  /// Get panel builder
  PanelContentBuilder? getPanelBuilder(String id) => _panelBuilders[id];

  /// Get all builders (including static and dynamic)
  Map<String, PanelContentBuilder> get panelBuilders =>
      Map.unmodifiable(_panelBuilders);

  /// Set initial panel builders (called once at startup)
  void setInitialBuilders(Map<String, PanelContentBuilder> builders) {
    _panelBuilders.addAll(builders);
  }

  void _notifyListeners() {
    _panelsController.add(Map.unmodifiable(_panels));
  }

  void dispose() {
    _panelsController.close();
  }
}
