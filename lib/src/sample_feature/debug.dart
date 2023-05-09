import 'dart:isolate';

import 'package:flutter/foundation.dart';

String getIsolateName() {
  if (kIsWeb) return "none";
  return Isolate.current.debugName ?? "unknown";
}
