import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

enum LiquidState {
  empty(1),
  filling(2),
  cooling(4),
  heating(5),
  stableTemperature(6);

  const LiquidState(this.value);
  final int value;

  static LiquidState fromValue(int value) {
    return LiquidState.values.firstWhere(
      (state) => state.value == value,
      orElse: () => LiquidState.empty,
    );
  }
}

enum TemperatureUnit {
  celsius(0),
  fahrenheit(1);

  const TemperatureUnit(this.value);
  final int value;

  static TemperatureUnit fromValue(int value) {
    return TemperatureUnit.values.firstWhere(
      (unit) => unit.value == value,
      orElse: () => TemperatureUnit.celsius,
    );
  }
}

class EmberProvider extends ChangeNotifier {

  int _batteryLevel = 0;
  bool _isCharging = false;
  double _currentTemp = 0.0;
  double _targetTemp = 0.0;
  LiquidState _liquidState = LiquidState.empty;
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  List<int> _color = [255, 255, 255, 255];
  String _name = 'Ember';

  int get batteryLevel => _batteryLevel;
  bool get isCharging => _isCharging;
  double get currentTemp => _currentTemp;
  double get targetTemp => _targetTemp;
  LiquidState get liquidState => _liquidState;
  TemperatureUnit get temperatureUnit => _temperatureUnit;
  List<int> get color => _color;
  String get name => _name;

  set targetTemp(double value) {
    if (value < 50 || value > 63) return;
    _targetTemp = value;
    _setTargetTemp(value);
    notifyListeners();
  }

  set temperatureUnit(TemperatureUnit value) {
    _temperatureUnit = value;
    _setTemperatureUnit(value);
    notifyListeners();
  }

  set color(List<int> value) {
    _color = value;
    _setColor(value);
    notifyListeners();
  }

  BluetoothCharacteristic? _targetTempCharacteristic;
  BluetoothCharacteristic? _currentTempCharacteristic;
  BluetoothCharacteristic? _batteryCharacteristic;
  BluetoothCharacteristic? _liquidStateCharacteristic;
  BluetoothCharacteristic? _temperatureUnitCharacteristic;
  BluetoothCharacteristic? _colorCharacteristic;
  BluetoothCharacteristic? _eventCharacteristic;

  StreamSubscription? _eventSubscription;

  void _setTargetTemp(double temp) {
    if (_targetTempCharacteristic == null) return;
    
    final uintVal = (temp * 100).toInt();
    final byte1 = uintVal & 0xFF;
    final byte2 = (uintVal >> 8) & 0xFF;
    
    final data = [byte1, byte2];
    _targetTempCharacteristic!.write(data);
  }

  void _setTemperatureUnit(TemperatureUnit unit) {
    if (_temperatureUnitCharacteristic == null) return;
    
    final data = [unit.value];
    _temperatureUnitCharacteristic!.write(data);
  }

  void _setColor(List<int> color) {
    if (_colorCharacteristic == null) return;
    
    final red = color.isNotEmpty ? color[0] : 255;
    final green = color.length > 1 ? color[1] : 255;
    final blue = color.length > 2 ? color[2] : 255;
    final alpha = color.length > 3 ? color[3] : 255;
    
    final data = [red, green, blue, alpha];
    _colorCharacteristic!.write(data);
  }

  Future<void> connect(BluetoothDevice device, BluetoothService service) async {
    _name = device.platformName;
    
    for (final characteristic in service.characteristics) {
      switch (characteristic.uuid.toString().toLowerCase()) {
        case "fc540003-236c-4c94-8fa9-944a3e5353fa":
          _targetTempCharacteristic = characteristic;
        case "fc540002-236c-4c94-8fa9-944a3e5353fa":
          _currentTempCharacteristic = characteristic;
        case "fc540007-236c-4c94-8fa9-944a3e5353fa":
          _batteryCharacteristic = characteristic;
        case "fc540008-236c-4c94-8fa9-944a3e5353fa":
          _liquidStateCharacteristic = characteristic;
        case "fc540004-236c-4c94-8fa9-944a3e5353fa":
          _temperatureUnitCharacteristic = characteristic;
        case "fc540014-236c-4c94-8fa9-944a3e5353fa":
          _colorCharacteristic = characteristic;
        case "fc540012-236c-4c94-8fa9-944a3e5353fa":
          _eventCharacteristic = characteristic;
          // Enable notifications for the event characteristic
          await characteristic.setNotifyValue(true);
        default:
          print("Unregistered characteristic ${characteristic.uuid}");
      }

      try {
        await _readCharacteristicValue(characteristic);
      } catch (e) {
        print("Error reading characteristic ${characteristic.uuid}: $e");
      }
    }

    // Set up event listener (mirroring Swift didUpdateValueFor)
    if (_eventCharacteristic != null) {
      _eventSubscription = _eventCharacteristic!.onValueReceived.listen(
        (data) => _handleEventUpdate(data),
      );
    }

    notifyListeners();
  }

  Future<void> _readCharacteristicValue(BluetoothCharacteristic? characteristic) async {
    if (characteristic == null) return;
    try {
      final data = await characteristic.read();
      _updateValueForCharacteristic(characteristic, data);
    } catch (e) {
      print("Error reading characteristic ${characteristic.uuid}: $e");
    }
  }

  void _updateValueForCharacteristic(BluetoothCharacteristic characteristic, List<int> data) {
    if (data.isEmpty) return;

    if (characteristic == _targetTempCharacteristic) {
      if (data.length >= 2) {
        final temp = (data[1] << 8) | data[0];
        _targetTemp = temp / 100.0;
      }
    } else if (characteristic == _currentTempCharacteristic) {
      if (data.length >= 2) {
        final temp = (data[1] << 8) | data[0];
        _currentTemp = temp / 100.0;
      }
    } else if (characteristic == _batteryCharacteristic) {
      if (data.length >= 2) {
        _batteryLevel = data[0];
        _isCharging = data[1] == 1;
      }
    } else if (characteristic == _liquidStateCharacteristic) {
      if (data.isNotEmpty) {
        _liquidState = LiquidState.fromValue(data[0]);
      }
    } else if (characteristic == _temperatureUnitCharacteristic) {
      if (data.isNotEmpty) {
        _temperatureUnit = TemperatureUnit.fromValue(data[0]);
      }
    } else if (characteristic == _colorCharacteristic) {
      if (data.length >= 4) {
        _color = [data[0], data[1], data[2], data[3]];
      }
    }

    notifyListeners();
  }

  void _handleEventUpdate(List<int> data) {
    if (data.isEmpty) return;

    final state = data[0];

    switch (state) {
      case 1:
        _readCharacteristicValue(_batteryCharacteristic!);
        break;
      case 2:
        _isCharging = true;
        notifyListeners();
        break;
      case 3:
        _isCharging = false;
        notifyListeners();
        break;
      case 4:
        _readCharacteristicValue(_targetTempCharacteristic);
        break;
      case 5:
        _readCharacteristicValue(_currentTempCharacteristic);
        break;
      case 8:
        _readCharacteristicValue(_liquidStateCharacteristic);
        break;
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}