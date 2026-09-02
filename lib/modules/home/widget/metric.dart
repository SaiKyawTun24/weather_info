import 'package:flutter/material.dart';
import 'package:weather_info/core/constant/style.dart';

class Metric extends StatelessWidget {
  const Metric({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.metricLabel),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.metricValue),
        ],
      ),
    );
  }
}
