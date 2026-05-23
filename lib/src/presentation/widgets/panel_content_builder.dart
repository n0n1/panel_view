import 'package:flutter/material.dart';

/// Builder configuration for panel content.
///
/// This class defines how a panel's content should be built,
/// including its title, icon, and the actual content widget.
class PanelContentBuilder {
  /// Optional title for the panel header
  final String? title;

  /// Optional icon for the panel header
  final IconData? icon;

  /// Builder function that creates the panel content
  final WidgetBuilder builder;

  /// Optional callback when panel is closed
  final VoidCallback? onClose;

  /// Optional custom header builder
  /// If provided, this will be used instead of the default header
  final Widget Function(VoidCallback onClose)? customHeaderBuilder;

  const PanelContentBuilder({
    this.title,
    this.icon,
    required this.builder,
    this.onClose,
    this.customHeaderBuilder,
  });

  /// Build the content widget
  Widget build(BuildContext context) => builder(context);

  /// Create a copy with updated values
  PanelContentBuilder copyWith({
    String? title,
    IconData? icon,
    WidgetBuilder? builder,
    VoidCallback? onClose,
    Widget Function(VoidCallback onClose)? customHeaderBuilder,
  }) {
    return PanelContentBuilder(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      builder: builder ?? this.builder,
      onClose: onClose ?? this.onClose,
      customHeaderBuilder: customHeaderBuilder ?? this.customHeaderBuilder,
    );
  }
}
