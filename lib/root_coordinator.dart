import 'package:flutter/material.dart';

import 'apps/app_a.dart';
import 'apps/app_b.dart';
import 'apps/chooser_app.dart';

enum DemoApp { chooser, appA, appB }

class RootCoordinator extends StatefulWidget {
  const RootCoordinator({super.key});

  @override
  State<RootCoordinator> createState() => _RootCoordinatorState();
}

class _RootCoordinatorState extends State<RootCoordinator> {
  DemoApp _currentApp = DemoApp.chooser;
  late final String _instanceId = identityHashCode(this).toString();

  void _show(DemoApp app) {
    setState(() => _currentApp = app);
  }

  @override
  Widget build(BuildContext context) {
    final coordinatorLabel = '根协调器实例：$_instanceId';

    return switch (_currentApp) {
      DemoApp.chooser => ChooserApp(
        key: const ValueKey('chooser-app'),
        coordinatorLabel: coordinatorLabel,
        onOpenAppA: () => _show(DemoApp.appA),
        onOpenAppB: () => _show(DemoApp.appB),
      ),
      DemoApp.appA => AppA(
        key: const ValueKey('app-a'),
        coordinatorLabel: coordinatorLabel,
        onBack: () => _show(DemoApp.chooser),
        onSwitch: () => _show(DemoApp.appB),
      ),
      DemoApp.appB => AppB(
        key: const ValueKey('app-b'),
        coordinatorLabel: coordinatorLabel,
        onBack: () => _show(DemoApp.chooser),
        onSwitch: () => _show(DemoApp.appA),
      ),
    };
  }
}
