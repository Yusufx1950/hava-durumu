import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:modern_weather/services/weather_service.dart';
import '../models/weather_model.dart';
import 'package:modern_weather/services/weather_service.dart';

// Events
abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeather extends WeatherEvent {}

class RefreshWeather extends WeatherEvent {}

// States
abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final Weather weather;

  const WeatherLoaded(this.weather);

  @override
  List<Object?> get props => [weather];
}

class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherService _weatherService = WeatherService();

  WeatherBloc() : super(WeatherInitial()) {
    on<LoadWeather>(_onLoadWeather);
    on<RefreshWeather>(_onRefreshWeather);
  }

  Future<void> _onLoadWeather(
    LoadWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());
    try {
      final position = await _weatherService.getCurrentLocation();
      final weather = await _weatherService.getWeather(
        position.latitude,
        position.longitude,
      );
      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    try {
      final position = await _weatherService.getCurrentLocation();
      final weather = await _weatherService.getWeather(
        position.latitude,
        position.longitude,
      );
      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }
}
