import 'lib/screens/reports/create_report_screen.dart';
import 'lib/screens/reports/edit_report_screen.dart';import 'package:flutter/material.dart';


String formatTimeOfDay(TimeOfDay? time) {
  if (time == null) {
    return 'Unknown time';
  }

  // 格式化时间为 HH:mm 格式
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return "$hours:$minutes";
}


