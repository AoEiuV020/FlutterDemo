import 'package:demo/src/db/database.dart';
import 'package:demo/src/view/database_operator.dart';
import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatefulWidget {
  const SampleItemDetailsView({super.key});

  static const routeName = '/sample_item';

  @override
  State<SampleItemDetailsView> createState() => _SampleItemDetailsViewState();
}

class _SampleItemDetailsViewState extends State<SampleItemDetailsView> {
  AppDatabase? database;

  void initDatabase() async {
    setState(() {
      database = AppDatabase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final database = this.database;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drift TodoItems'),
      ),
      body: database == null
          ? Center(
              child: ElevatedButton(
                onPressed: initDatabase,
                child: const Text('init database'),
              ),
            )
          : DatabaseOperator(database),
    );
  }
}
