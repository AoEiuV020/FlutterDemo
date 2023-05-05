import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView(this.str, {super.key});

  static const routeName = '/sample_item';

  final String str;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('More Information Here'),
            Text(str),
          ],
        ),
      ),
    );
  }
}
