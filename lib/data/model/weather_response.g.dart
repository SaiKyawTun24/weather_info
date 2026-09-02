// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherResponse _$WeatherResponseFromJson(Map<String, dynamic> json) =>
    WeatherResponse(
      location: json['location'] == null
          ? null
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      current: json['current'] == null
          ? null
          : Current.fromJson(json['current'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WeatherResponseToJson(WeatherResponse instance) =>
    <String, dynamic>{
      'location': instance.location,
      'current': instance.current,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  name: json['name'] as String?,
  region: json['region'] as String?,
  country: json['country'] as String?,
  lat: (json['lat'] as num?)?.toDouble(),
  lon: (json['lon'] as num?)?.toDouble(),
  tzId: json['tz_id'] as String?,
  localtimeEpoch: (json['localtime_epoch'] as num?)?.toInt(),
  localtime: json['localtime'] as String?,
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'name': instance.name,
  'region': instance.region,
  'country': instance.country,
  'lat': instance.lat,
  'lon': instance.lon,
  'tz_id': instance.tzId,
  'localtime_epoch': instance.localtimeEpoch,
  'localtime': instance.localtime,
};

Current _$CurrentFromJson(Map<String, dynamic> json) => Current(
  tempC: (json['temp_c'] as num?)?.toDouble(),
  tempF: (json['temp_f'] as num?)?.toDouble(),
  isDay: (json['is_day'] as num?)?.toInt(),
  condition: json['condition'] == null
      ? null
      : Condition.fromJson(json['condition'] as Map<String, dynamic>),
  humidity: (json['humidity'] as num?)?.toInt(),
  cloud: (json['cloud'] as num?)?.toInt(),
);

Map<String, dynamic> _$CurrentToJson(Current instance) => <String, dynamic>{
  'temp_c': instance.tempC,
  'temp_f': instance.tempF,
  'is_day': instance.isDay,
  'condition': instance.condition,
  'humidity': instance.humidity,
  'cloud': instance.cloud,
};

Condition _$ConditionFromJson(Map<String, dynamic> json) => Condition(
  text: json['text'] as String?,
  icon: json['icon'] as String?,
  code: (json['code'] as num?)?.toInt(),
);

Map<String, dynamic> _$ConditionToJson(Condition instance) => <String, dynamic>{
  'text': instance.text,
  'icon': instance.icon,
  'code': instance.code,
};
