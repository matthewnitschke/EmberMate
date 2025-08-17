import 'package:ember_mate/components/button.dart';
import 'package:ember_mate/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:provider/provider.dart';
import 'package:ember_mate/providers/ember_provider.dart';
import 'package:ember_mate/providers/app_state_provider.dart';

class Presets extends StatelessWidget {
  const Presets({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<EmberProvider, AppStateProvider>(
      builder: (context, emberProvider, appStateProvider, child) {
        return Wrap(
          alignment: WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: appStateProvider.presets.map((preset) => 
            Button(
              width: 90,
              height: 90,
              onTap: () {
                appStateProvider.togglePreset(preset);
                emberProvider.targetTemp = preset.temperature;
              },
              isSelected: appStateProvider.selectedPreset == preset,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(preset.name, style: TextStyle(fontSize: 10)),
                    SFIcon(preset.icon, color: Colors.white, fontSize: 26),
                    Text(
                      getFormattedTemperature(
                        preset.temperature, 
                        emberProvider.temperatureUnit,
                      ), 
                      style: TextStyle(fontSize: 10),
                    )
                  ],
                ),
              )
            )
          ).toList(),
        );
      },
    );
  }
}
