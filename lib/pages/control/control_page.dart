import 'package:ember_mate/components/battery_icon.dart';
import 'package:ember_mate/components/button.dart';
import 'package:ember_mate/components/gradient_background.dart';
import 'package:ember_mate/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:provider/provider.dart';
import 'package:ember_mate/providers/ember_provider.dart';
import 'package:ember_mate/providers/app_state_provider.dart';
import 'package:ember_mate/pages/control/presets.dart';

class MugControlPage extends StatelessWidget {
  const MugControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      topColor: const Color.fromRGBO(212, 212, 212, 1),
      bottomColor: const Color.fromRGBO(69, 69, 69, 1),
      child: Consumer2<EmberProvider, AppStateProvider>(
        builder: (context, emberProvider, appStateProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    emberProvider.name,
                    style: TextStyle(
                      fontSize: 11
                    ),
                  ),
                  BatteryIcon(),
                ],
              ),
          
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Button(
                      width: 30,
                      onTap: () {
                        emberProvider.targetTemp -= 0.5;
                        appStateProvider.clearSelectedPreset();
                      },
                      child: SFIcon(
                        SFIcons.sf_chevron_left,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          emberProvider.liquidState == LiquidState.empty
                            ? 'Empty'
                            : getFormattedTemperature(
                                emberProvider.currentTemp, 
                                emberProvider.temperatureUnit,
                              ),
                          style: TextStyle(fontSize: 25)
                        ),
                        Text(
                          'Target: ${getFormattedTemperature(emberProvider.targetTemp, emberProvider.temperatureUnit)}',
                        ),
                      ],
                    ),
                    Button(
                      width: 30,
                      onTap: () {
                        emberProvider.targetTemp += 0.5;
                        appStateProvider.clearSelectedPreset();
                      },
                      child: SFIcon(
                        SFIcons.sf_chevron_right,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              Presets(),
              // TimerWidget(),
            ],
          );
        },
      ),
    );
  }
}
