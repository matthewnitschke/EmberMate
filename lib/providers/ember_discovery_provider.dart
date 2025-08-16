import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class EmberDiscoveryProvider extends ChangeNotifier{
  final List<BluetoothDevice> _discoveredMugs = [];

  bool _isScanning = false;

  List<BluetoothDevice> get discoveredMugs => List.unmodifiable(_discoveredMugs);
  bool get isScanning => _isScanning;

  EmberDiscoveryProvider() {
    FlutterBluePlus.setLogLevel(LogLevel.none);
    
    FlutterBluePlus.isScanning.listen((isScanning) {
      _isScanning = isScanning;
      notifyListeners();
    });
  }

  Future<void> startScanning() async {
    if (_isScanning) return;

    _isScanning = true;
    _discoveredMugs.clear();

    try {
      // Check if Bluetooth is supported
      if (await FlutterBluePlus.isSupported == false) {
        throw Exception("Bluetooth not supported by this device");
      }

      // Check if Bluetooth is on
      if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
        throw Exception("Bluetooth is not enabled. Please turn on Bluetooth.");
      }

      // Start scanning for Ember mugs (using the Ember service UUID)
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        withServices: [Guid("FC543622-236C-4C94-8FA9-944A3E5353FA")],
        androidUsesFineLocation: false,
      );

      // Listen for scan results
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!_discoveredMugs.contains(result.device)) {
            _discoveredMugs.add(result.device);
            notifyListeners();
          }
        }
      });

    } catch (e) {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> stopScanning() async {
    if (!_isScanning) return;

    await FlutterBluePlus.stopScan();
    _isScanning = false;
    notifyListeners();
  }

  Future<BluetoothService?> connect(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));

      final services = await device.discoverServices();
      final service = services.firstWhereOrNull(
        (s) => s.uuid == Guid("FC543622-236C-4C94-8FA9-944A3E5353FA")
      );
      if (service == null) {
        throw Exception('Device is missing Ember service');
      }

      return service;
    } catch (e) {
      return null;
    }
  }
}