import 'package:flutter/material.dart';

class AppBDetailPage extends StatelessWidget {
  const AppBDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('应用 B 内部页面')),
      body: Center(
        child: FilledButton.icon(
          key: const ValueKey('back-to-app-b-home'),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          label: const Text('返回应用 B 首页'),
        ),
      ),
    );
  }
}
