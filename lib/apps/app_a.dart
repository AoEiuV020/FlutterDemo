import 'package:flutter/material.dart';

import 'app_b.dart';
import '../widgets/demo_page.dart';

class AppA extends StatelessWidget {
  const AppA({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '应用 A',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      home: const _AppAHome(),
    );
  }
}

class _AppAHome extends StatefulWidget {
  const _AppAHome();

  @override
  State<_AppAHome> createState() => _AppAHomeState();
}

class _AppAHomeState extends State<_AppAHome> {
  int _counter = 0;

  Future<void> _openAppB() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (outerRouteContext) =>
            AppB(onExit: () => Navigator.of(outerRouteContext).pop()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: '应用 A',
      description: '应用 A 计数：$_counter',
      coordinatorLabel: '应用 A 是唯一根应用',
      actions: [
        FilledButton.icon(
          key: const ValueKey('increment-app-a'),
          onPressed: () => setState(() => _counter++),
          icon: const Icon(Icons.add),
          label: const Text('增加应用 A 计数'),
        ),
        OutlinedButton.icon(
          key: const ValueKey('open-app-b'),
          onPressed: _openAppB,
          icon: const Icon(Icons.open_in_new),
          label: const Text('打开应用 B'),
        ),
      ],
    );
  }
}
