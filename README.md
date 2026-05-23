# panel_view

A reusable draggable and resizable panel system for Flutter apps.

## Overview

The `panel_view` package provides a generic, customizable panel component that can be used throughout an application to display content in floating, repositionable windows.

## Features

- Draggable positioning
- Configurable size constraints
- Custom content widgets
- Optional headers with title/icon/close
- Resize handles
- Global panel manager + overlay

## Usage

Add `panel_view` to your app and import the package:

```dart
import 'package:panel_view/panel_view.dart';
```

Use `DraggablePanel` for a standalone floating panel:

```dart
Stack(
  children: [
    DraggablePanel(
      config: const PanelConfig(id: 'my_panel'),
      title: 'My Panel',
      icon: Icons.info_outline,
      onClose: () {
        // Handle close
      },
      child: const Text('Panel content'),
    ),
  ],
)
```

## Managed Panels

Use `PanelManagerService` with `GlobalPanelOverlay` when panels need to be
opened from different parts of the app.

```dart
final panelManager = PanelManagerService();

panelManager.registerPanel(const PanelConfig(id: 'notes_panel'));
panelManager.registerPanelBuilder(
  'notes_panel',
  PanelContentBuilder(
    title: 'Notes',
    icon: Icons.notes,
    builder: (context) => const Text('Notes content'),
  ),
);

panelManager.openPanel('notes_panel');
```

## Global Overlay

Place `GlobalPanelOverlay` above route content, for example with
`MaterialApp.builder`:

```dart
MaterialApp(
  builder: (context, child) {
    return Stack(
      children: [
        if (child != null) child,
        GlobalPanelOverlay(panelManager: panelManager),
      ],
    );
  },
)
```
