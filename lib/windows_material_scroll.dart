import 'dart:ui';
import 'package:flutter/material.dart';

class WindowsMaterialScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse, // Mouse ile sürüklemeyi aktif eder
  };
}
