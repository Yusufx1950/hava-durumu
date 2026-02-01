import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Konum servisi kapalı');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Konum izni reddedildi');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Konum izni kalıcı olarak reddedildi');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> getCityName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        return placemarks.first.locality ??
            placemarks.first.subAdministrativeArea ??
            'Bilinmeyen Konum';
      }
    } catch (e) {
      debugPrint('Şehir adı alınamadı: $e');
    }
    return 'Bilinmeyen Konum';
  }

  Future<Weather> getWeather(double lat, double lon) async {
    try {
      final cityName = await getCityName(lat, lon);

      // REST API çağrısı
      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'latitude': lat.toString(),
          'longitude': lon.toString(),
          'current':
              'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
          'hourly': 'temperature_2m,weather_code',
          'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
          'timezone': 'auto',
          'forecast_days': '7',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('API Hatası: ${response.statusCode}');
      }

      final data = json.decode(response.body);

      // Mevcut hava durumu
      final current = data['current'];
      final currentUnits = data['current_units'];

      // Saatlik tahmin
      final hourly = data['hourly'];
      final hourlyForecast = <HourlyForecast>[];

      if (hourly != null) {
        final times = List<String>.from(hourly['time'] ?? []);
        final temps = List<double>.from(
          (hourly['temperature_2m'] ?? []).map((e) => (e as num).toDouble()),
        );
        final codes = List<int>.from(
          (hourly['weather_code'] ?? []).map((e) => (e as num).toInt()),
        );

        final now = DateTime.now();

        for (var i = 0; i < times.length && hourlyForecast.length < 24; i++) {
          final time = DateTime.parse(times[i]);
          if (time.isAfter(now) && i < temps.length && i < codes.length) {
            hourlyForecast.add(
              HourlyForecast(
                time: time,
                temperature: temps[i],
                weatherCode: codes[i],
              ),
            );
          }
        }
      }

      // Günlük tahmin
      final daily = data['daily'];
      final dailyForecast = <DailyForecast>[];

      if (daily != null) {
        final dates = List<String>.from(daily['time'] ?? []);
        final maxTemps = List<double>.from(
          (daily['temperature_2m_max'] ?? []).map((e) => (e as num).toDouble()),
        );
        final minTemps = List<double>.from(
          (daily['temperature_2m_min'] ?? []).map((e) => (e as num).toDouble()),
        );
        final codes = List<int>.from(
          (daily['weather_code'] ?? []).map((e) => (e as num).toInt()),
        );

        for (var i = 0; i < dates.length && i < 7; i++) {
          if (i < maxTemps.length && i < minTemps.length && i < codes.length) {
            dailyForecast.add(
              DailyForecast(
                date: DateTime.parse(dates[i]),
                maxTemp: maxTemps[i],
                minTemp: minTemps[i],
                weatherCode: codes[i],
              ),
            );
          }
        }
      }

      return Weather(
        temperature: (current['temperature_2m'] as num).toDouble(),
        feelsLike: (current['apparent_temperature'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).toInt(),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        weatherCode: (current['weather_code'] as num).toInt(),
        cityName: cityName,
        date: DateTime.now(),
        dailyForecast: dailyForecast,
        hourlyForecast: hourlyForecast,
      );
    } catch (e) {
      throw Exception('Hava durumu verisi alınamadı: $e');
    }
  }

  // WMO Weather interpretation codes (Open-Meteo)
  static String getWeatherIcon(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '☁️';
    if (code <= 48) return '🌫️';
    if (code <= 55) return '🌦️';
    if (code <= 65) return '🌧️';
    if (code <= 77) return '🌨️';
    if (code <= 82) return '🌦️';
    if (code <= 86) return '🌨️';
    if (code <= 99) return '⛈️';
    return '☀️';
  }

  static String getWeatherDescription(int code) {
    if (code == 0) return 'Açık';
    if (code == 1) return 'Parçalı Bulutlu';
    if (code == 2) return 'Bulutlu';
    if (code == 3) return 'Kapalı';
    if (code <= 48) return 'Sisli';
    if (code <= 55) return 'Çiseleme';
    if (code <= 65) return 'Yağmurlu';
    if (code <= 77) return 'Karlı';
    if (code <= 82) return 'Sağanak';
    if (code <= 86) return 'Kar Fırtınası';
    if (code <= 99) return 'Gök Gürültülü';
    return 'Bilinmiyor';
  }

  static List<Color> getWeatherGradient(int code) {
    if (code == 0) return [const Color(0xFFFFA726), const Color(0xFFFF7043)];
    if (code <= 3) return [const Color(0xFF42A5F5), const Color(0xFF1976D2)];
    if (code <= 48) return [const Color(0xFF78909C), const Color(0xFF455A64)];
    if (code <= 65) return [const Color(0xFF5C6BC0), const Color(0xFF3F51B5)];
    if (code <= 77) return [const Color(0xFF90CAF9), const Color(0xFF42A5F5)];
    if (code <= 99) return [const Color(0xFF263238), const Color(0xFF102027)];
    return [const Color(0xFF42A5F5), const Color(0xFF1976D2)];
  }
}
