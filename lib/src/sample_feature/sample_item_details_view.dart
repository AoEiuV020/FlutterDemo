import 'package:demo/src/sample_feature/sample_item.dart';
import 'package:demo/src/util/json.dart';
import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView(this.item, {super.key});

  factory SampleItemDetailsView.create(String str) {
    var item = SampleItem.fromJson(jsonFromString(str));
    return SampleItemDetailsView(item);
  }

  static const routeName = '/sample_item';

  final SampleItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('More Information Here'),
            const SizedBox(height: 10),
            Text('${item.id}'),
          ],
        ),
      ),
    );
  }
}
