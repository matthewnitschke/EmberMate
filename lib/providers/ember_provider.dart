import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

enum LiquidState {
  empty,
  filling,
  cooling,
  heating,
  stableTemperature;
}

enum TemperatureUnit {
  celsius(0),
  fahrenheit(1);

  const TemperatureUnit(this.value);
  final int value;
}

class EmberProvider extends ChangeNotifier {
  StreamSubscription? _eventSubscription;
  
  double get targetTemperature => _targetTempChar.value ?? 0.0;

  double get currentTemperature => _currentTempChar.value ?? 0.0;
  int get batteryLevel => _batteryChar.value ?? 0;
  bool get isCharging => _isChargingChar.value ?? false;
  LiquidState get liquidState => _liquidStateChar.value ?? LiquidState.empty;
  TemperatureUnit get temperatureUnit => _temperatureUnitChar.value ?? TemperatureUnit.celsius;
  List<int> get color => _colorChar.value ?? [255, 255, 255, 255];
  
  set targetTemperature(double value) {
    if (value < 50 || value > 63) return;
    _targetTempChar.writeValue(value);
    notifyListeners();
  }
  set temperatureUnit(TemperatureUnit value) {
    _temperatureUnitChar.writeValue(value);
    notifyListeners();
  }
  set color(List<int> value) {
    _colorChar.writeValue(value);
    notifyListeners();
  }

  final _targetTempChar = EmberCharacteristic<double>(
    uuid: "fc540003-236c-4c94-8fa9-944a3e5353fa",
    stateIndex: 4,
    onRead: (data) {
      if (data.length != 2) return 0.0;
      int tempRaw = (data[1] << 8) | data[0];
      return tempRaw / 100.0;
    },
    onWrite: (value) {
      final temp = (value * 100).toInt();
      return [
        temp & 0xFF,
        (temp >> 8) & 0xFF,
      ];
    }
  );

  final _currentTempChar = EmberCharacteristic<double>(
    uuid: "fc540002-236c-4c94-8fa9-944a3e5353fa",
    stateIndex: 5,
    onRead: (data) {
      if (data.length != 2) return 0.0;
      int tempRaw = (data[1] << 8) | data[0];
      return tempRaw / 100.0;
    },
  );

  final _batteryChar = EmberCharacteristic<int>(
    uuid: "fc540007-236c-4c94-8fa9-944a3e5353fa",
    stateIndex: 1,
    onRead: (data) {
      if (data.isEmpty) return 0;
      return data[0];
    },
  );

  final _isChargingChar = EmberCharacteristic<bool>(
    uuid: "fc540007-236c-4c94-8fa9-944a3e5353fa",
    stateIndex: 1,
    onRead: (data) {
      if (data.length != 2) return false;
      return data[1] == 1;
    },
  );

  final _liquidStateChar = EmberCharacteristic<LiquidState>(
    uuid: "fc540008-236c-4c94-8fa9-944a3e5353fa",
    stateIndex: 8,
    onRead: (data) {
      if (data.isEmpty) return LiquidState.empty;
      switch (data[0]) {
        case 1: return LiquidState.empty;
        case 2: return LiquidState.filling;
        case 4: return LiquidState.cooling;
        case 5: return LiquidState.heating;
        case 6: return LiquidState.stableTemperature;
        default: return LiquidState.empty;
      }
    },
  );

  final _temperatureUnitChar = EmberCharacteristic<TemperatureUnit>(
    uuid: "fc540004-236c-4c94-8fa9-944a3e5353fa",
    onRead: (data) {
      if (data.isEmpty) return TemperatureUnit.celsius;
      switch (data[0]) {
        case 0: return TemperatureUnit.celsius;
        case 1: return TemperatureUnit.fahrenheit;
        default: return TemperatureUnit.celsius;
      }
    },
    onWrite: (value) {
      return [value.value];
    },
  );

  final _colorChar = EmberCharacteristic<List<int>>(
    uuid: "fc540014-236c-4c94-8fa9-944a3e5353fa",
    onRead: (data) {
      if (data.length >= 4) {
        return [data[0], data[1], data[2], data[3]];
      }
      return [255, 255, 255, 255]; // Default white
    },
    onWrite: (value) {
      if (value.length >= 4) {
        return [value[0], value[1], value[2], value[3]];
      }
      return [255, 255, 255, 255];
    },
  );

  Future<void> connect(BluetoothService service) async {
    final eventCharacteristic = service.characteristics.firstWhere(
      (c) => c.uuid == Guid("fc540012-236c-4c94-8fa9-944a3e5353fa")
    );
    await eventCharacteristic.setNotifyValue(true);
    _eventSubscription = eventCharacteristic.onValueReceived.listen(
      (value) {
        if (value.isEmpty) return;

        final char = EmberCharacteristic.all.firstWhereOrNull(
          (c) => c.stateIndex == value[0],
        );
        if (char == null) return;

        char.readValue().then((_) => notifyListeners());
      }
    );

    for (var char in EmberCharacteristic.all) {
      char.setup(service);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}


class EmberCharacteristic<T> {
  final String uuid;
  final int? stateIndex;

  final T? Function(List<int> data) onRead;
  final List<int> Function(T value)? onWrite;

  T? value;

  static final _all = <EmberCharacteristic>[];
  static List<EmberCharacteristic> get all => _all;

  BluetoothCharacteristic? _characteristic;

  EmberCharacteristic({
    required this.uuid,
    required this.onRead,
    this.stateIndex,
    this.onWrite,
  }) {
    _all.add(this);
  }

  Future<void> setup(BluetoothService service) async {
    _characteristic = service.characteristics.firstWhere(
      (c) => c.uuid == Guid(uuid),
    );

    await readValue(); // read the initial value
  }

  Future<void> readValue() async {
    value = onRead(await _characteristic!.read());
  }

  Future<void> writeValue(T value) async {
    this.value = value;

    if (onWrite == null) return;
    final data = onWrite!(value);
    await _characteristic!.write(data);
  }
}