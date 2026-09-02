// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weather_info/main.dart';
import 'package:weather_info/modules/home/provider/weather_provider.dart';

void main() {
  testWidgets('shows the weather search screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [weatherProvider.overrideWith(_FakeWeatherNotifier.new)],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Find your weather'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}

class _FakeWeatherNotifier extends WeatherNotifier {
  @override
  WeatherState build() {
    return const WeatherState();
  }

  @override
  void setLoading(bool value) {}
}
