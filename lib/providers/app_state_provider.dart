import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sficon/flutter_sficon.dart';

class Preset {
  final String name;
  final double temperature;
  final IconData icon;

  const Preset({
    required this.name,
    required this.temperature,
    required this.icon,
  });
}

class Timer {
  final String name;
  final Duration duration;
  final bool isActive;

  const Timer({
    required this.name,
    required this.duration,
    this.isActive = false,
  });

  Timer copyWith({
    String? name,
    Duration? duration,
    bool? isActive,
  }) {
    return Timer(
      name: name ?? this.name,
      duration: duration ?? this.duration,
      isActive: isActive ?? this.isActive,
    );
  }
}

class AppStateProvider extends ChangeNotifier {
  Preset? selectedPreset;

  final List<Preset> _presets = [
    const Preset(
      name: 'Latte',
      temperature: 52.0,
      icon: SFIcons.sf_cup_and_saucer_fill,
    ),
    const Preset(
      name: 'Coffee',
      temperature: 55.0,
      icon: SFIcons.sf_mug_fill,
    ),
    const Preset(
      name: 'Tea',
      temperature: 58.0,
      icon: SFIcons.sf_cup_and_saucer,
    ),
  ];

  final List<Timer> _timers = [
    const Timer(name: '4:00', duration: Duration(minutes: 4)),
    const Timer(name: '8:00', duration: Duration(minutes: 8)),
    const Timer(name: '12:00', duration: Duration(minutes: 12)),
  ];

  List<Preset> get presets => List.unmodifiable(_presets);
  List<Timer> get timers => List.unmodifiable(_timers);

  void togglePreset(Preset preset) {
    if (preset == selectedPreset) {
      selectedPreset = null;
    } else {
      selectedPreset = preset;
    }
    notifyListeners();
  }

  void clearSelectedPreset() {
    selectedPreset = null;
    notifyListeners();
  }

  void updatePreset(int index, Preset preset) {
    if (index >= 0 && index < _presets.length) {
      _presets[index] = preset;
      notifyListeners();
    }
  }

  void addTimer(Timer timer) {
    _timers.add(timer);
    notifyListeners();
  }

  void removeTimer(int index) {
    if (index >= 0 && index < _timers.length) {
      _timers.removeAt(index);
      notifyListeners();
    }
  }

  void updateTimer(int index, Timer timer) {
    if (index >= 0 && index < _timers.length) {
      _timers[index] = timer;
      notifyListeners();
    }
  }

  void toggleTimer(int index) {
    if (index >= 0 && index < _timers.length) {
      _timers[index] = _timers[index].copyWith(
        isActive: !_timers[index].isActive,
      );
      notifyListeners();
    }
  }

  void deactivateAllTimers() {
    for (int i = 0; i < _timers.length; i++) {
      if (_timers[i].isActive) {
        _timers[i] = _timers[i].copyWith(isActive: false);
      }
    }
    notifyListeners();
  }

  Timer? get activeTimer {
    try {
      return _timers.firstWhere((timer) => timer.isActive);
    } catch (e) {
      return null;
    }
  }

  Preset? getPresetByName(String name) {
    try {
      return _presets.firstWhere((preset) => preset.name == name);
    } catch (e) {
      return null;
    }
  }

  Timer? getTimerByName(String name) {
    try {
      return _timers.firstWhere((timer) => timer.name == name);
    } catch (e) {
      return null;
    }
  }
}
