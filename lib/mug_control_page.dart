import 'package:ember_mate/button.dart';
import 'package:ember_mate/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:provider/provider.dart';
import 'package:ember_mate/providers/ember_provider.dart';

class MugControlPage extends StatelessWidget {
  const MugControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      topColor: const Color.fromRGBO(212, 212, 212, 1),
      bottomColor: const Color.fromRGBO(69, 69, 69, 1),
      child: Consumer<EmberProvider>(
        builder: (context, emberProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EmberCup 2', 
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11
                    ),
                  ), 
                  SFIcon(
                    SFIcons.sf_battery_100percent,
                    fontSize: 13,
                    color: Colors.white,
                  )
                ],
              ),
          
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Button(
                      width: 30,
                      onTap: () => emberProvider.targetTemperature -= 0.5,
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
                          emberProvider.currentTemperature.toStringAsFixed(1), 
                          style: TextStyle(fontSize: 25, color: Colors.white)
                        ),
                        Text(
                          'Target: ${emberProvider.targetTemperature.toStringAsFixed(1)}°',
                          style: TextStyle(color: Colors.white)
                        ),
                      ],
                    ),
                    Button(
                      width: 30,
                      onTap: () => emberProvider.targetTemperature += 0.5,
                      child: SFIcon(
                        SFIcons.sf_chevron_right,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  Button(
                    width: 90,
                    height: 90,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Latte', style: TextStyle(fontSize: 10, color: Colors.white)),
                          SFIcon(
                            SFIcons.sf_cup_and_saucer_fill,
                            color: Colors.white,
                            fontSize: 26,
                          ),
                          Text('52°', style: TextStyle(fontSize: 10, color: Colors.white))
                        ],
                      ),
                    )
                  ),
                  Button(
                    width: 90,
                    height: 90,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Coffee', style: TextStyle(fontSize: 10, color: Colors.white)),
                          SFIcon(
                            SFIcons.sf_mug_fill,
                            color: Colors.white,
                            fontSize: 26,
                          ),
                          Text('55°', style: TextStyle(fontSize: 10, color: Colors.white))
                        ],
                      ),
                    )
                  ),
                ],
              ),

              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .29), 
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      spacing: 8, 
                      children: [
                        SFIcon(SFIcons.sf_timer, color: Colors.white, fontSize: 26),
                        Text('Timer', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Button(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 9),
                            child: Text('4:00', style: TextStyle(color: Colors.white)),
                          )
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
