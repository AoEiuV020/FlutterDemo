import 'package:flutter/material.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({
    super.key,
    required this.title,
    required this.description,
    required this.coordinatorLabel,
    required this.actions,
  });

  final String title;
  final String description;
  final String coordinatorLabel;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 16,
              children: [
                Icon(
                  Icons.layers,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  coordinatorLabel,
                  key: const ValueKey('coordinator-id'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ...actions.map(
                  (action) => SizedBox(width: double.infinity, child: action),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
