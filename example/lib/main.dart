import 'package:flutter/material.dart';
import 'package:panel_view/panel_view.dart';

void main() {
  runApp(const PanelViewExampleApp());
}

class PanelViewExampleApp extends StatefulWidget {
  const PanelViewExampleApp({super.key});

  @override
  State<PanelViewExampleApp> createState() => _PanelViewExampleAppState();
}

class _PanelViewExampleAppState extends State<PanelViewExampleApp> {
  late final PanelManagerService _panelManager;

  @override
  void initState() {
    super.initState();
    _panelManager = PanelManagerService()
      ..registerPanel(
        const PanelConfig(
          id: 'notes',
          initialPosition: Offset(48, 96),
          initialWidth: 360,
          initialHeight: 280,
          minWidth: 280,
          minHeight: 180,
        ),
      )
      ..registerPanel(
        const PanelConfig(
          id: 'inspector',
          initialPosition: Offset(460, 96),
          initialWidth: 320,
          initialHeight: 260,
          minWidth: 260,
          minHeight: 180,
        ),
      )
      ..setInitialBuilders({
        'notes': PanelContentBuilder(
          title: 'Notes',
          icon: Icons.notes,
          builder: (_) => const _NotesPanel(),
        ),
        'inspector': PanelContentBuilder(
          title: 'Inspector',
          icon: Icons.tune,
          builder: (_) => const _InspectorPanel(),
        ),
      });
  }

  @override
  void dispose() {
    _panelManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'panel_view example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            GlobalPanelOverlay(panelManager: _panelManager),
          ],
        );
      },
      home: _ExampleHome(panelManager: _panelManager),
    );
  }
}

class _ExampleHome extends StatelessWidget {
  final PanelManagerService panelManager;

  const _ExampleHome({required this.panelManager});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('panel_view example')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Open draggable, resizable panels above the app content.',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () => panelManager.togglePanel('notes'),
                      icon: const Icon(Icons.notes),
                      label: const Text('Toggle notes'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _toggleInspector(context),
                      icon: const Icon(Icons.tune),
                      label: const Text('Toggle inspector'),
                    ),
                    OutlinedButton.icon(
                      onPressed: panelManager.closeAllPanels,
                      icon: const Icon(Icons.close),
                      label: const Text('Close all'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Drag panels by their body and resize them from the edges '
                      'or corners.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleInspector(BuildContext context) {
    final inspector = panelManager.getPanel('inspector');
    if (inspector?.isOpen ?? false) {
      panelManager.closePanel('inspector');
      return;
    }

    final mediaQuery = MediaQuery.of(context);
    final safeArea = mediaQuery.padding;
    final viewport = mediaQuery.size;
    final panelWidth = (viewport.width - 32).clamp(260.0, 320.0).toDouble();
    final panelHeight = (viewport.height * 0.42).clamp(220.0, 260.0).toDouble();
    final left =
        ((viewport.width - panelWidth) / 2).clamp(16.0, viewport.width);
    final top = (viewport.height - safeArea.bottom - panelHeight - 24).clamp(
      safeArea.top + 16,
      viewport.height,
    );

    panelManager.updateSize('inspector', Size(panelWidth, panelHeight));
    panelManager.updatePosition(
        'inspector', Offset(left.toDouble(), top.toDouble()));
    panelManager.openPanel('inspector');
  }
}

class _NotesPanel extends StatelessWidget {
  const _NotesPanel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Write notes here...',
        ),
      ),
    );
  }
}

class _InspectorPanel extends StatelessWidget {
  const _InspectorPanel();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Selected item', style: textTheme.titleMedium),
        const SizedBox(height: 12),
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.widgets),
          title: Text('Widget'),
          subtitle: Text('ResizablePanel'),
        ),
        const Divider(),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Enabled'),
          value: true,
          onChanged: (_) {},
        ),
      ],
    );
  }
}
