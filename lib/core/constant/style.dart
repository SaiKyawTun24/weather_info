import 'package:flutter/material.dart';

import 'color_const.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle appBarTitle = TextStyle(fontWeight: FontWeight.w800);
  static const TextStyle heroTitle = TextStyle(
    fontSize: 34,
    height: 1.05,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle cityName = TextStyle(
    color: AppColors.white,
    fontSize: 28,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle tempValue = TextStyle(
    color: AppColors.white,
    fontSize: 64,
    height: 0.95,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle conditionText = TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle metricValue = TextStyle(
    color: AppColors.white,
    fontSize: 17,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle errorBody = TextStyle(color: AppColors.errorText);

  static TextStyle get subtitle =>
      TextStyle(color: AppColors.blueGrey700, fontSize: 16);

  static TextStyle get locationMeta => TextStyle(color: AppColors.blueGrey100);
  static TextStyle get metricLabel => TextStyle(color: AppColors.blueGrey200);
}
