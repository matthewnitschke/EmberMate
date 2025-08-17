import 'package:ember_mate/providers/ember_provider.dart';

String getFormattedTemperature(double temperature, TemperatureUnit unit) {
  if (unit == TemperatureUnit.celsius) {
    return "${temperature.toStringAsFixed(1)}°";
  }

  final fahrenheit = (temperature * 9 / 5) + 32;
  return "${fahrenheit.round()}°";
}