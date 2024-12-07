import 'package:flutter/material.dart';
import 'lib/components/custom_info_window_test.dart';

class CustomInfoWindow extends StatelessWidget {
  final String license_plate;
  final String violation;
  final String address;
  final String date;
  final String time;
  final String officer;
  final String status;

  const CustomInfoWindow({
    super.key,
    required this.licensePlate,
    required this.violation,
    required this.address,
    required this.date,
    required this.time,
    required this.officer,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('車牌: $licensePlate', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('違規項目: $violation',style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('地點: $address',style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('日期: $date',style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('時間: $time',style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('承辦人: $officer',style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('開單情況: $status',style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
