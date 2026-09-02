import 'package:weather_info/data/model/weather_response.dart';
import 'package:weather_info/data/repository/repository.dart';
import '../api_service/api_service.dart';
import '../local_storage/shared_preferences_service.dart';

class RepositoryImpl extends Repository {
  final ApiService apiService;
  final SharedPreferencesService sharedPreferencesService;

  RepositoryImpl({
    required this.apiService,
    required this.sharedPreferencesService,
  });

  @override
  Future<WeatherResponse> getCurrentWeather(String city) {
    return apiService.getCurrentWeather(city: city);
  }
}
