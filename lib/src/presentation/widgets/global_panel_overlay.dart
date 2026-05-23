import 'package:flutter/material.dart';

import 'package:panel_view/src/domain/entities/panel_state.dart';
import 'package:panel_view/src/domain/services/panel_manager_service.dart';
import 'package:panel_view/src/presentation/widgets/resizable_panel.dart';

/// Global overlay that renders all panels managed by PanelManagerService
/// This widget should be placed at the root of the app to ensure panels
/// are rendered above all route content
class GlobalPanelOverlay extends StatelessWidget {
  final PanelManagerService panelManager;

  const GlobalPanelOverlay({super.key, required this.panelManager});

  @override
  Widget build(BuildContext context) {
    // Panels are rendered as siblings to the Navigator in `MaterialApp.builder`,
    // so they don't automatically have access to the app Overlay.
    //
    // Provide a local Overlay so Tooltip and EditableText (selection handles,
    // context menu) can work inside panels. Keep stream listening inside the
    // Overlay entry builder so panel rendering stays reactive.
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (overlayContext) {
            return StreamBuilder<Map<String, PanelState>>(
              stream: panelManager.panelsStream,
              builder: (context, snapshot) {
                final panels = panelManager.getOpenPanelsSorted();
                final builders = panelManager.panelBuilders;

                if (panels.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Stack(
                  children: panels.map((panel) {
                    final builder = builders[panel.id];
                    if (builder == null) {
                      return const SizedBox.shrink();
                    }

                    void onCloseCallback() {
                      panelManager.closePanel(panel.id);
                      builder.onClose?.call();
                    }

                    return ResizablePanel(
                      key: ValueKey(panel.id),
                      panelId: panel.id,
                      panelManager: panelManager,
                      title: builder.title,
                      icon: builder.icon,
                      header: builder.customHeaderBuilder?.call(
                        onCloseCallback,
                      ),
                      onClose: onCloseCallback,
                      child: builder.builder(overlayContext),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
