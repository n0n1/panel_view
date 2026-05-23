import 'package:flutter/material.dart';

/// Configuration for a draggable panel
class PanelConfig {
  /// Unique identifier for the panel
  final String id;

  /// Initial position offset (if null, will be calculated automatically)
  final Offset? initialPosition;

  /// Initial width (if null, will use default or maxWidth)
  final double? initialWidth;

  /// Initial height (if null, will use default or maxHeight)
  final double? initialHeight;

  /// Maximum width constraint
  final double? maxWidth;

  /// Maximum height constraint
  final double? maxHeight;

  /// Minimum width constraint
  final double? minWidth;

  /// Minimum height constraint
  final double? minHeight;

  /// Whether the panel should be dismissible
  final bool isDismissible;

  /// Opacity when dragging (0.0 - 1.0)
  final double dragOpacity;

  /// Whether to show shadow
  final bool showShadow;

  /// Border radius
  final double borderRadius;

  const PanelConfig({
    required this.id,
    this.initialPosition,
    this.initialWidth,
    this.initialHeight,
    this.maxWidth = 400,
    this.maxHeight = 500,
    this.minWidth = 200,
    this.minHeight = 100,
    this.isDismissible = true,
    this.dragOpacity = 0.8,
    this.showShadow = true,
    this.borderRadius = 12,
  });

  PanelConfig copyWith({
    String? id,
    Offset? initialPosition,
    double? initialWidth,
    double? initialHeight,
    double? maxWidth,
    double? maxHeight,
    double? minWidth,
    double? minHeight,
    bool? isDismissible,
    double? dragOpacity,
    bool? showShadow,
    double? borderRadius,
  }) {
    return PanelConfig(
      id: id ?? this.id,
      initialPosition: initialPosition ?? this.initialPosition,
      initialWidth: initialWidth ?? this.initialWidth,
      initialHeight: initialHeight ?? this.initialHeight,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      isDismissible: isDismissible ?? this.isDismissible,
      dragOpacity: dragOpacity ?? this.dragOpacity,
      showShadow: showShadow ?? this.showShadow,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}
