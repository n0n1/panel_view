import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:panel_view/src/domain/entities/panel_config.dart';

/// State of a panel in the panel management system
class PanelState extends Equatable {
  /// Unique identifier for the panel
  final String id;

  /// Current position of the panel
  final Offset position;

  /// Current size of the panel
  final Size size;

  /// Z-index for stacking order (higher = on top)
  final int zIndex;

  /// Whether the panel is currently open/visible
  final bool isOpen;

  /// Whether the panel is minimized
  final bool isMinimized;

  /// Configuration for panel constraints and behavior
  final PanelConfig config;

  /// Timestamp when panel was last focused
  final DateTime lastFocused;

  PanelState({
    required this.id,
    required this.position,
    required this.size,
    required this.zIndex,
    required this.config,
    this.isOpen = false,
    this.isMinimized = false,
    DateTime? lastFocused,
  }) : lastFocused = lastFocused ?? DateTime.now();

  /// Create initial state from config
  factory PanelState.fromConfig(PanelConfig config) {
    return PanelState(
      id: config.id,
      position: config.initialPosition ?? const Offset(100, 100),
      size: Size(
        config.initialWidth ?? config.maxWidth ?? 400,
        config.initialHeight ?? config.maxHeight ?? 500,
      ),
      zIndex: 0,
      config: config,
      isOpen: false,
    );
  }

  /// Copy with new values
  PanelState copyWith({
    String? id,
    Offset? position,
    Size? size,
    int? zIndex,
    bool? isOpen,
    bool? isMinimized,
    PanelConfig? config,
    DateTime? lastFocused,
  }) {
    return PanelState(
      id: id ?? this.id,
      position: position ?? this.position,
      size: size ?? this.size,
      zIndex: zIndex ?? this.zIndex,
      isOpen: isOpen ?? this.isOpen,
      isMinimized: isMinimized ?? this.isMinimized,
      config: config ?? this.config,
      lastFocused: lastFocused ?? this.lastFocused,
    );
  }

  /// Update position
  PanelState movedTo(Offset newPosition) {
    return copyWith(position: newPosition, lastFocused: DateTime.now());
  }

  /// Update size
  PanelState resizedTo(Size newSize) {
    // Clamp size to min/max constraints
    final clampedWidth = newSize.width
        .clamp(config.minWidth ?? 200, config.maxWidth ?? double.infinity)
        .toDouble();
    final clampedHeight = newSize.height
        .clamp(config.minHeight ?? 100, config.maxHeight ?? double.infinity)
        .toDouble();

    return copyWith(
      size: Size(clampedWidth, clampedHeight),
      lastFocused: DateTime.now(),
    );
  }

  /// Bring to front (increase z-index)
  PanelState bringToFront(int newZIndex) {
    return copyWith(zIndex: newZIndex, lastFocused: DateTime.now());
  }

  /// Open panel
  PanelState open() {
    return copyWith(
      isOpen: true,
      isMinimized: false,
      lastFocused: DateTime.now(),
    );
  }

  /// Close panel
  PanelState close() {
    return copyWith(isOpen: false);
  }

  /// Toggle minimize state
  PanelState toggleMinimize() {
    return copyWith(isMinimized: !isMinimized);
  }

  @override
  List<Object?> get props => [
        id,
        position,
        size,
        zIndex,
        isOpen,
        isMinimized,
        config,
        lastFocused,
      ];
}
