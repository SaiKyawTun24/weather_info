import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:retrofit/retrofit.dart';

import '../../core/config/app_config.dart';
import '../model/weather_response.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  static ApiService create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
        },
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters['key'] = AppConfig.apiKey;
          return handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),
    );

    return ApiService(
      dio,
      baseUrl: AppConfig.baseUrl,
    );
  }

  @GET('/current.json')
  Future<WeatherResponse> getCurrentWeather({
    @Query('q') required String city,
  });
}