import 'package:flutter/material.dart';

import 'package:panel_view/src/domain/entities/panel_config.dart';

/// A draggable panel widget that can contain any content
/// This is a reusable component for displaying floating panels
class DraggablePanel extends StatefulWidget {
  /// Configuration for the panel appearance and behavior
  final PanelConfig config;

  /// The content to display inside the panel
  final Widget child;

  /// Callback when panel is closed/dismissed
  final VoidCallback? onClose;

  /// Optional header widget (overrides default header)
  final Widget? header;

  /// Panel title (used in default header)
  final String? title;

  /// Panel icon (used in default header)
  final IconData? icon;

  const DraggablePanel({
    super.key,
    required this.config,
    required this.child,
    this.onClose,
    this.header,
    this.title,
    this.icon,
  });

  @override
  State<DraggablePanel> createState() => _DraggablePanelState();
}

class _DraggablePanelState extends State<DraggablePanel> {
  late Offset _position;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _position = widget.config.initialPosition ?? const Offset(0, 20);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized && widget.config.initialPosition == null) {
      final screenWidth = MediaQuery.of(context).size.width;
      final panelWidth = widget.config.maxWidth ?? 400;
      _position = Offset(screenWidth - panelWidth - 20, 20);
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Draggable(
        feedback: _buildPanelContent(isDragging: true),
        childWhenDragging: _buildPanelContent(isPlaceholder: true),
        onDragEnd: (details) {
          setState(() {
            _position = details.offset;
          });
        },
        child: _buildPanelContent(),
      ),
    );
  }

  Widget _buildPanelContent({
    bool isDragging = false,
    bool isPlaceholder = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget content = Container(
      constraints: BoxConstraints(
        maxWidth: widget.config.maxWidth ?? 400,
        maxHeight: widget.config.maxHeight ?? 500,
        minWidth: widget.config.minWidth ?? 200,
        minHeight: widget.config.minHeight ?? 100,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(widget.config.borderRadius),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: widget.config.showShadow
            ? [
                BoxShadow(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.header ?? _buildDefaultHeader(),
          Divider(
            height: 1,
            color: colorScheme.outline.withValues(alpha: 0.5),
            thickness: 0.5,
          ),
          Flexible(child: widget.child),
        ],
      ),
    );

    if (isDragging) {
      content = Material(
        color: Colors.transparent,
        child: Opacity(opacity: widget.config.dragOpacity, child: content),
      );
    } else if (isPlaceholder) {
      content = Opacity(opacity: 0.3, child: content);
    }

    return content;
  }

  Widget _buildDefaultHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
          ],
          if (widget.title != null)
            Text(
              widget.title!,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          const Spacer(),
          if (widget.onClose != null && widget.config.isDismissible)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: widget.onClose,
              tooltip: 'Close',
              color: colorScheme.onSurfaceVariant,
              hoverColor: colorScheme.error.withValues(alpha: 0.2),
              iconSize: 18,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
