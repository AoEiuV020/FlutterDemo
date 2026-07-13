import 'package:flutter/material.dart';

import '../widgets/demo_page.dart';

class AppA extends StatefulWidget {
  const AppA({
    super.key,
    required this.coordinatorLabel,
    required this.onBack,
    required this.onSwitch,
  });

  final String coordinatorLabel;
  final VoidCallback onBack;
  final VoidCallback onSwitch;

  @override
  State<AppA> createState() => _AppAState();
}

class _AppAState extends State<AppA> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '应用 A',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: DemoPage(
        title: '应用 A',
        description: '应用 A 计数：$_counter',
        coordinatorLabel: widget.coordinatorLabel,
        actions: [
          FilledButton.icon(
            key: const ValueKey('increment-app-a'),
            onPressed: () => setState(() => _counter++),
            icon: const Icon(Icons.add),
            label: const Text('增加应用 A 计数'),
          ),
          OutlinedButton(
            key: const ValueKey('switch-to-app-b'),
            onPressed: widget.onSwitch,
            child: const Text('切换到应用 B'),
          ),
          TextButton(
            key: const ValueKey('app-a-back'),
            onPressed: widget.onBack,
            child: const Text('返回选择应用'),
          ),
        ],
      ),
    );
  }
}
