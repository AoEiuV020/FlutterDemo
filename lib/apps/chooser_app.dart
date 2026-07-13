import 'package:flutter/material.dart';

import '../widgets/demo_page.dart';

class ChooserApp extends StatelessWidget {
  const ChooserApp({
    super.key,
    required this.coordinatorLabel,
    required this.onOpenAppA,
    required this.onOpenAppB,
  });

  final String coordinatorLabel;
  final VoidCallback onOpenAppA;
  final VoidCallback onOpenAppB;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '选择应用',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: DemoPage(
        title: '选择应用',
        description: '请选择要挂载的应用',
        coordinatorLabel: coordinatorLabel,
        actions: [
          FilledButton.icon(
            key: const ValueKey('open-app-a'),
            onPressed: onOpenAppA,
            icon: const Icon(Icons.looks_one),
            label: const Text('打开应用 A'),
          ),
          FilledButton.icon(
            key: const ValueKey('open-app-b'),
            onPressed: onOpenAppB,
            icon: const Icon(Icons.looks_two),
            label: const Text('打开应用 B'),
          ),
        ],
      ),
    );
  }
}
