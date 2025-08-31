import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key});

  static const double _defaultLat = 19.432608;
  static const double _defaultLon = -99.133209;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return Row(
      children: [
        const Icon(Icons.thermostat, size: 20),
        const SizedBox(width: 5),
        FutureBuilder<double>(
          future: fetchWeatherCelsius(_defaultLat, _defaultLon),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Cargando...', style: textStyle);
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Text('Sin datos', style: textStyle);
            }
            return Text('${snapshot.data!.toStringAsFixed(1)} °C', style: textStyle);
          },
        ),
      ],
    );
  }
}

Future<double> fetchWeatherCelsius(double lat, double lon) async {
  final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': lat.toString(),
    'longitude': lon.toString(),
    'current_weather': 'true',
    'timezone': 'auto',
  });

  final response = await http.get(uri);
  if (response.statusCode != 200) {
    throw Exception('Error al obtener clima');
  }

  final data = json.decode(response.body);
  return (data['current_weather']['temperature'] as num).toDouble();
}
