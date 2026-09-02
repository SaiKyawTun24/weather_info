import '../model/weather_response.dart';

abstract class Repository {
  Future<WeatherResponse> getCurrentWeather(String city);
}
