import 'package:ember_mate/components/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:provider/provider.dart';
import 'package:ember_mate/providers/app_state_provider.dart';

class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appStateProvider, child) {
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .29), 
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                spacing: 8, 
                children: [
                  SFIcon(SFIcons.sf_timer, color: Colors.white, fontSize: 20),
                  Text('Timer'),
                ],
              ),
              Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.end,
                children: appStateProvider.timers.map((timer) => 
                  Button(
                    onTap: () => appStateProvider.toggleTimer(appStateProvider.timers.indexOf(timer)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 9),
                      child: Text(
                        timer.name,
                        style: TextStyle(
                          color: timer.isActive ? Colors.green : null,
                          fontSize: 12,
                        ),
                      ),
                    )
                  )
                ).toList(),
              )
            ],
          ),
        );
      },
    );
  }
}
