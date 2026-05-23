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

```dart
import 'package:panel_view/panel_view.dart';

DraggablePanel(
  config: const PanelConfig(id: 'my_panel'),
  title: 'My Panel',
  icon: Icons.info_outline,
  onClose: () {
    // Handle close
  },
  child: YourContentWidget(),
)
```

## Panel Manager

```dart
final panelManager = PanelManagerService();

panelManager.registerPanel(const PanelConfig(id: 'notes_panel'));
panelManager.openPanel('notes_panel');
```

## Global Overlay

```dart
GlobalPanelOverlay(panelManager: panelManager)
```
