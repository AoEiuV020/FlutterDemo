import 'package:flutter/material.dart';

import '../widgets/demo_page.dart';

class AppB extends StatefulWidget {
  const AppB({
    super.key,
    required this.coordinatorLabel,
    required this.onBack,
    required this.onSwitch,
  });

  final String coordinatorLabel;
  final VoidCallback onBack;
  final VoidCallback onSwitch;

  @override
  State<AppB> createState() => _AppBState();
}

class _AppBState extends State<AppB> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '应用 B',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: DemoPage(
        title: '应用 B',
        description: '应用 B 计数：$_counter',
        coordinatorLabel: widget.coordinatorLabel,
        actions: [
          FilledButton.icon(
            key: const ValueKey('increment-app-b'),
            onPressed: () => setState(() => _counter++),
            icon: const Icon(Icons.add),
            label: const Text('增加应用 B 计数'),
          ),
          OutlinedButton(
            key: const ValueKey('switch-to-app-a'),
            onPressed: widget.onSwitch,
            child: const Text('切换到应用 A'),
          ),
          TextButton(
            key: const ValueKey('app-b-back'),
            onPressed: widget.onBack,
            child: const Text('返回选择应用'),
          ),
        ],
      ),
    );
  }
}
