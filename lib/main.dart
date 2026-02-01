import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart'; // BU GEREKLİ
import 'package:modern_weather/bloc/weather_bloc.dart';
import 'package:modern_weather/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TÜRKÇE AYARLARINI BAŞLAT
  await initializeDateFormatting('tr_TR');

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherBloc()..add(LoadWeather()),
      child: MaterialApp(
        title: 'Hava Durumu',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
