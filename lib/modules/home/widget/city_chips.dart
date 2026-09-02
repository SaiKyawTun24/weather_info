import 'package:flutter/material.dart';

class CityChips extends StatelessWidget {
  const CityChips({super.key, required this.cities, required this.onTap});

  final List<String> cities;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cities
          .map(
            (city) => ActionChip(
              label: Text(city),
              onPressed: () => onTap(city),
              avatar: const Icon(Icons.location_on_outlined, size: 18),
            ),
          )
          .toList(),
    );
  }
}
