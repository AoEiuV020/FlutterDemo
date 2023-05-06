import 'dart:io';

import 'package:path/path.dart';

/// A placeholder class that represents an entity or model.
class SampleItem {
  const SampleItem(this.entity);

  final FileSystemEntity entity;

  String getName() {
    return basename(entity.path);
  }
}
