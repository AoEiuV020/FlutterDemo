import 'package:flutter/material.dart';

import 'app_b_detail_page.dart';
import '../widgets/demo_page.dart';

class AppB extends StatelessWidget {
  const AppB({super.key, required this.onExit});

  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '应用 B',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: _AppBHome(onExit: onExit),
    );
  }
}

class _AppBHome extends StatefulWidget {
  const _AppBHome({required this.onExit});

  final VoidCallback onExit;

  @override
  State<_AppBHome> createState() => _AppBHomeState();
}

class _AppBHomeState extends State<_AppBHome> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: '应用 B',
      description: '应用 B 计数：$_counter',
      coordinatorLabel: '应用 B 保留独立 MaterialApp 和 Navigator',
      actions: [
        FilledButton.icon(
          key: const ValueKey('increment-app-b'),
          onPressed: () => setState(() => _counter++),
          icon: const Icon(Icons.add),
          label: const Text('增加应用 B 计数'),
        ),
        OutlinedButton(
          key: const ValueKey('open-app-b-detail'),
          onPressed: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => const AppBDetailPage()),
            );
          },
          child: const Text('打开应用 B 内部页面'),
        ),
        TextButton(
          key: const ValueKey('exit-app-b'),
          onPressed: widget.onExit,
          child: const Text('退出应用 B 并返回应用 A'),
        ),
      ],
    );
  }
}
