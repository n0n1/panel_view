import 'package:flutter/material.dart';

import 'package:panel_view/src/domain/services/panel_manager_service.dart';

/// A panel widget with drag and resize capabilities
/// Integrates with PanelManagerService for global state management
class ResizablePanel extends StatefulWidget {
  final String panelId;
  final PanelManagerService panelManager;
  final Widget child;
  final Widget? header;
  final String? title;
  final IconData? icon;
  final VoidCallback? onClose;

  const ResizablePanel({
    super.key,
    required this.panelId,
    required this.panelManager,
    required this.child,
    this.header,
    this.title,
    this.icon,
    this.onClose,
  });

  @override
  State<ResizablePanel> createState() => _ResizablePanelState();
}

class _ResizablePanelState extends State<ResizablePanel> {
  bool _isDragging = false;
  bool _isResizing = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: widget.panelManager.panelsStream,
      builder: (context, snapshot) {
        final panel = widget.panelManager.getPanel(widget.panelId);
        if (panel == null || !panel.isOpen) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: panel.position.dx,
          top: panel.position.dy,
          child: GestureDetector(
            onTap: () {
              widget.panelManager.bringToFront(widget.panelId);
            },
            onPanStart: (_) {
              setState(() => _isDragging = true);
              widget.panelManager.bringToFront(widget.panelId);
            },
            onPanUpdate: (details) {
              final newPosition = Offset(
                panel.position.dx + details.delta.dx,
                panel.position.dy + details.delta.dy,
              );
              widget.panelManager.updatePosition(widget.panelId, newPosition);
            },
            onPanEnd: (_) {
              setState(() => _isDragging = false);
            },
            child: AnimatedOpacity(
              opacity: _isDragging ? 0.7 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: _buildPanelContent(panel),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPanelContent(dynamic panel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: panel.size.width,
      height: panel.size.height,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(panel.config.borderRadius),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: panel.config.showShadow
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
      child: Stack(
        children: [
          // Main content with Material wrapper for TextField/IconButton support
          Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                widget.header ?? _buildDefaultHeader(),

                // Divider
                Divider(
                  height: 1,
                  color: colorScheme.outline.withValues(alpha: 0.5),
                  thickness: 0.5,
                ),

                // Content
                Expanded(child: widget.child),
              ],
            ),
          ),

          // Resize handles
          _buildResizeHandles(panel),
        ],
      ),
    );
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
          if (widget.onClose != null)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResizeHandles(dynamic panel) {
    const handleSize = 12.0;

    return Stack(
      children: [
        // Bottom-right corner handle (most common)
        Positioned(
          right: 0,
          bottom: 0,
          child: _buildResizeHandle(
            handleSize,
            SystemMouseCursors.resizeDownRight,
            (delta) {
              final newSize = Size(
                panel.size.width + delta.dx,
                panel.size.height + delta.dy,
              );
              widget.panelManager.updateSize(widget.panelId, newSize);
            },
          ),
        ),

        // Right edge handle
        Positioned(
          right: 0,
          top: handleSize,
          bottom: handleSize,
          child: _buildResizeHandle(
            handleSize,
            SystemMouseCursors.resizeRight,
            (delta) {
              final newSize = Size(
                panel.size.width + delta.dx,
                panel.size.height,
              );
              widget.panelManager.updateSize(widget.panelId, newSize);
            },
            isEdge: true,
          ),
        ),

        // Bottom edge handle
        Positioned(
          bottom: 0,
          left: handleSize,
          right: handleSize,
          child: _buildResizeHandle(handleSize, SystemMouseCursors.resizeDown, (
            delta,
          ) {
            final newSize = Size(
              panel.size.width,
              panel.size.height + delta.dy,
            );
            widget.panelManager.updateSize(widget.panelId, newSize);
          }, isEdge: true),
        ),

        // Bottom-left corner handle
        Positioned(
          left: 0,
          bottom: 0,
          child: _buildResizeHandle(
            handleSize,
            SystemMouseCursors.resizeDownLeft,
            (delta) {
              final newSize = Size(
                panel.size.width - delta.dx,
                panel.size.height + delta.dy,
              );
              final newPosition = Offset(
                panel.position.dx + delta.dx,
                panel.position.dy,
              );
              widget.panelManager.updateSize(widget.panelId, newSize);
              widget.panelManager.updatePosition(widget.panelId, newPosition);
            },
          ),
        ),

        // Top-right corner handle
        Positioned(
          right: 0,
          top: 0,
          child: _buildResizeHandle(
            handleSize,
            SystemMouseCursors.resizeUpRight,
            (delta) {
              final newSize = Size(
                panel.size.width + delta.dx,
                panel.size.height - delta.dy,
              );
              final newPosition = Offset(
                panel.position.dx,
                panel.position.dy + delta.dy,
              );
              widget.panelManager.updateSize(widget.panelId, newSize);
              widget.panelManager.updatePosition(widget.panelId, newPosition);
            },
          ),
        ),

        // Top-left corner handle
        Positioned(
          left: 0,
          top: 0,
          child: _buildResizeHandle(
            handleSize,
            SystemMouseCursors.resizeUpLeft,
            (delta) {
              final newSize = Size(
                panel.size.width - delta.dx,
                panel.size.height - delta.dy,
              );
              final newPosition = Offset(
                panel.position.dx + delta.dx,
                panel.position.dy + delta.dy,
              );
              widget.panelManager.updateSize(widget.panelId, newSize);
              widget.panelManager.updatePosition(widget.panelId, newPosition);
            },
          ),
        ),

        // Left edge handle
        Positioned(
          left: 0,
          top: handleSize,
          bottom: handleSize,
          child: _buildResizeHandle(handleSize, SystemMouseCursors.resizeLeft, (
            delta,
          ) {
            final newSize = Size(
              panel.size.width - delta.dx,
              panel.size.height,
            );
            final newPosition = Offset(
              panel.position.dx + delta.dx,
              panel.position.dy,
            );
            widget.panelManager.updateSize(widget.panelId, newSize);
            widget.panelManager.updatePosition(widget.panelId, newPosition);
          }, isEdge: true),
        ),

        // Top edge handle
        Positioned(
          top: 0,
          left: handleSize,
          right: handleSize,
          child: _buildResizeHandle(handleSize, SystemMouseCursors.resizeUp, (
            delta,
          ) {
            final newSize = Size(
              panel.size.width,
              panel.size.height - delta.dy,
            );
            final newPosition = Offset(
              panel.position.dx,
              panel.position.dy + delta.dy,
            );
            widget.panelManager.updateSize(widget.panelId, newSize);
            widget.panelManager.updatePosition(widget.panelId, newPosition);
          }, isEdge: true),
        ),
      ],
    );
  }

  Widget _buildResizeHandle(
    double size,
    MouseCursor cursor,
    Function(Offset delta) onResize, {
    bool isEdge = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: cursor,
      child: GestureDetector(
        onPanStart: (_) {
          setState(() => _isResizing = true);
        },
        onPanUpdate: (details) {
          onResize(details.delta);
        },
        onPanEnd: (_) {
          setState(() => _isResizing = false);
        },
        child: Container(
          width: isEdge ? null : size,
          height: isEdge ? null : size,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: _isResizing
                ? Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    width: 2,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
