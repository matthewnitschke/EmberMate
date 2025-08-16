import 'package:ember_mate/providers/ember_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:provider/provider.dart';

class BatteryIcon extends StatelessWidget {
  const BatteryIcon({super.key});

  IconData _icon(bool isCharging, int batteryLevel) {
    if (isCharging) {
      return SFIcons.sf_battery_100percent_bolt;
    }

    final segement = (batteryLevel / 25).round() * 25;

    switch (segement) {
      case 0: return SFIcons.sf_battery_0percent;
      case 25: return SFIcons.sf_battery_25percent;
      case 50: return SFIcons.sf_battery_50percent;
      case 75: return SFIcons.sf_battery_75percent;
      case 100: return SFIcons.sf_battery_100percent;
    }

    throw Exception('Invalid battery level: $batteryLevel');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmberProvider>(
      builder: (context, emberProvider, child) {
        return SFIcon(
          _icon(emberProvider.isCharging, emberProvider.batteryLevel),
          fontSize: 13,
          color: Colors.white,
        );
      },
    );
  }
}