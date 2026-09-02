import 'package:flutter/material.dart';
import 'package:weather_info/core/constant/color_const.dart';
import 'package:weather_info/core/constant/style.dart';
import 'package:weather_info/data/model/weather_response.dart';
import 'package:weather_info/modules/home/widget/metric.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    required this.weather,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final WeatherResponse weather;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final location = weather.location;
    final current = weather.current;
    final condition = current?.condition;
    final iconUrl = condition?.icon;
    final city = location?.name ?? 'Unknown city';

    return Card(
      elevation: 0,
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(city, style: AppTextStyles.cityName),
                      const SizedBox(height: 4),
                      Text(
                        [location?.region, location?.country]
                            .whereType<String>()
                            .where((part) => part.isNotEmpty)
                            .join(', '),
                        style: AppTextStyles.locationMeta,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onToggleFavorite,
                  tooltip: isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  color: isFavorite ? AppColors.yellow : AppColors.white,
                  icon: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (iconUrl != null)
                      Image.network(
                        iconUrl.startsWith('//') ? 'https:$iconUrl' : iconUrl,
                        width: 72,
                        height: 72,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.cloud_rounded,
                          color: AppColors.white,
                          size: 64,
                        ),
                      ),
                    const SizedBox(width: 12),
                    Text(
                      '${current?.tempC?.round() ?? '--'}°',
                      style: AppTextStyles.tempValue,
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  condition?.text ?? 'Current conditions unavailable',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.conditionText,
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Metric(
                  label: 'Humidity',
                  value: '${current?.humidity ?? '--'}%',
                ),
                Metric(
                  label: 'Wind speed',
                  value: '${current?.windKph?.toStringAsFixed(1) ?? '--'} km/h',
                ),
                Metric(
                  label: 'Cloud cover',
                  value: '${current?.cloud ?? '--'}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
