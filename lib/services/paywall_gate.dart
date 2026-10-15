import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:golf_training_app/views/screens/choose_plan/choose_plan_screen.dart';

/// Opens Choose Plan once when a premium route returns HTTP 402.
class PaywallGate {
  static bool _opening = false;

  static void open() {
    if (_opening) return;
    final context = Get.key.currentContext ?? Get.context;
    if (context == null) return;
    _opening = true;
    Navigator.of(context)
        .push<bool>(
          MaterialPageRoute(builder: (_) => const ChoosePlanScreen()),
        )
        .whenComplete(() {
      _opening = false;
    });
  }
}
