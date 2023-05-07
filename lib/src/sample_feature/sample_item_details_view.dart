import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatelessWidget {
  const SampleItemDetailsView(this.currentFile, {super.key});

  static const routeName = '/sample_item';

  final File currentFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentFile.path),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Text(currentFile.readAsStringSync()),
        ),
      ),
    );
  }
}
