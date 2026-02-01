import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:modern_weather/bloc/weather_bloc.dart';
import 'package:modern_weather/models/weather_model.dart';
import 'package:modern_weather/services/weather_service.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, state) {
          if (state is WeatherLoading || state is WeatherInitial) {
            return const LoadingView();
          } else if (state is WeatherError) {
            return ErrorView(message: (state as WeatherError).message);
          } else if (state is WeatherLoaded) {
            return WeatherView(weather: (state as WeatherLoaded).weather);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class WeatherView extends StatelessWidget {
  final Weather weather;

  const WeatherView({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    try {
      DateFormat('EEEE', 'tr_TR');
    } catch (e) {
      initializeDateFormatting('tr_TR', null);
    }
    final gradientColors = WeatherService.getWeatherGradient(
      weather.weatherCode,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<WeatherBloc>().add(RefreshWeather());
          },
          color: Colors.white,
          backgroundColor: Colors.white24,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Üst Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GlassContainer(
                            child: IconButton(
                              icon: const Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          Text(
                            'Hava Durumu',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          GlassContainer(
                            child: IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                context.read<WeatherBloc>().add(
                                  RefreshWeather(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Konum ve Tarih
                      Text(
                        weather.cityName,
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'EEEE, d MMMM',
                          'tr_TR',
                        ).format(weather.date),
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Ana Hava Durumu Kartı
                      GlassCard(
                        child: Column(
                          children: [
                            Text(
                              WeatherService.getWeatherIcon(
                                weather.weatherCode,
                              ),
                              style: const TextStyle(fontSize: 80),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${weather.temperature.round()}°',
                              style: GoogleFonts.inter(
                                fontSize: 72,
                                fontWeight: FontWeight.w200,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              WeatherService.getWeatherDescription(
                                weather.weatherCode,
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Detaylar Grid
                      Row(
                        children: [
                          Expanded(
                            child: GlassCard(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.thermostat,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${weather.feelsLike.round()}°',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Hissedilen',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GlassCard(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.water_drop,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${weather.humidity}%',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Nem',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GlassCard(
                              child: Column(
                                children: [
                                  const Icon(Icons.air, color: Colors.white70),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${weather.windSpeed.round()}',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'km/sa',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Saatlik Tahmin
                      Text(
                        'Saatlik Tahmin',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: weather.hourlyForecast.length,
                          itemBuilder: (context, index) {
                            final hourly = weather.hourlyForecast[index];
                            return HourlyForecastItem(hourly: hourly);
                          },
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 7 Günlük Tahmin
                      Text(
                        '7 Günlük Tahmin',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: weather.dailyForecast.length,
                        itemBuilder: (context, index) {
                          final daily = weather.dailyForecast[index];
                          return DailyForecastItem(daily: daily);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HourlyForecastItem extends StatelessWidget {
  final HourlyForecast hourly;

  const HourlyForecastItem({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('HH:mm').format(hourly.time),
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            WeatherService.getWeatherIcon(hourly.weatherCode),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            '${hourly.temperature.round()}°',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class DailyForecastItem extends StatelessWidget {
  final DailyForecast daily;

  const DailyForecastItem({super.key, required this.daily});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('EEEE', 'tr_TR').format(daily.date),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            WeatherService.getWeatherIcon(daily.weatherCode),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${daily.minTemp.round()}°',
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.white60),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.white38, Colors.white70],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${daily.maxTemp.round()}°',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;

  const GlassCard({super.key, required this.child, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: child,
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Shimmer.fromColors(
            baseColor: Colors.white24,
            highlightColor: Colors.white60,
            child: Column(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;

  const ErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEF5350), Color(0xFFC62828)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                Text(
                  'Bir Hata Oluştu',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    context.read<WeatherBloc>().add(LoadWeather());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Tekrar Dene',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
