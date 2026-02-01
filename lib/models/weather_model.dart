import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int weatherCode;
  final String cityName;
  final DateTime date;
  final double? maxTemp;
  final double? minTemp;
  final List<DailyForecast> dailyForecast;
  final List<HourlyForecast> hourlyForecast;

  const Weather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.cityName,
    required this.date,
    this.maxTemp,
    this.minTemp,
    this.dailyForecast = const [],
    this.hourlyForecast = const [],
  });

  Weather copyWith({
    double? temperature,
    double? feelsLike,
    int? humidity,
    double? windSpeed,
    int? weatherCode,
    String? cityName,
    DateTime? date,
    double? maxTemp,
    double? minTemp,
    List<DailyForecast>? dailyForecast,
    List<HourlyForecast>? hourlyForecast,
  }) {
    return Weather(
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      weatherCode: weatherCode ?? this.weatherCode,
      cityName: cityName ?? this.cityName,
      date: date ?? this.date,
      maxTemp: maxTemp ?? this.maxTemp,
      minTemp: minTemp ?? this.minTemp,
      dailyForecast: dailyForecast ?? this.dailyForecast,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
    );
  }

  @override
  List<Object?> get props => [
    temperature,
    feelsLike,
    humidity,
    windSpeed,
    weatherCode,
    cityName,
    date,
    maxTemp,
    minTemp,
    dailyForecast,
    hourlyForecast,
  ];
}

class DailyForecast extends Equatable {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  const DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });

  @override
  List<Object?> get props => [date, maxTemp, minTemp, weatherCode];
}

class HourlyForecast extends Equatable {
  final DateTime time;
  final double temperature;
  final int weatherCode;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
  });

  @override
  List<Object?> get props => [time, temperature, weatherCode];
}
