import 'dart:async';
import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../models/device.dart';
import 'device_discovery_service.dart';

class BluetoothDiscoveryService implements DeviceDiscoveryService {
  static final BluetoothDiscoveryService _instance =
      BluetoothDiscoveryService._internal();

  factory BluetoothDiscoveryService() {
    return _instance;
  }

  BluetoothDiscoveryService._internal();

  final _devicesStreamController = StreamController<List<Device>>.broadcast();
  final Set<Device> _discoveredDevices = {};
  bool _isScanning = false;
  StreamSubscription? _scanResultsSubscription;

  @override
  Stream<List<Device>> get devicesStream => _devicesStreamController.stream;

  @override
  Future<bool> isSupported() async {
    try {
      final isAvailable = await FlutterBluePlus.isAvailable;
      final isOn = await FlutterBluePlus.isOn;
      return isAvailable && isOn;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> startDiscovery() async {
    if (_isScanning) return;

    _discoveredDevices.clear();
    _devicesStreamController.add([]);

    try {
      _isScanning = true;

      _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          final device = Device(
            id: result.device.remoteId.str,
            name: result.device.platformName.isNotEmpty
                ? result.device.platformName
                : result.device.name,
            type: DeviceType.unknown,
            source: DeviceSource.bluetooth,
            distance: _calculateDistance(result.rssi),
          );

          _discoveredDevices.add(device);
          _devicesStreamController.add(_discoveredDevices.toList());
        }
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 30),
        androidScanMode: AndroidScanMode.lowLatency,
      );
    } catch (e) {
      _isScanning = false;
      rethrow;
    }
  }

  @override
  Future<void> stopDiscovery() async {
    if (!_isScanning) return;

    _isScanning = false;

    try {
      if (_scanResultsSubscription != null) {
        await _scanResultsSubscription?.cancel();
        _scanResultsSubscription = null;
      }

      await FlutterBluePlus.stopScan();
    } catch (e) {
      print('Error stopping Bluetooth discovery: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await stopDiscovery();

    try {
      if (!_devicesStreamController.isClosed) {
        await _devicesStreamController.close();
      }
    } catch (e) {
      print('Error disposing Bluetooth discovery service: $e');
    }
  }

  double? _calculateDistance(int rssi) {
    if (rssi == 0) return null;

    const int txPower = -59;

    if (rssi >= txPower) return 0.5;

    const double n = 2.5;

    final double rawDistance = pow(10, (txPower - rssi) / (10 * n)).toDouble();

    if (rawDistance < 0.5) return 0.5;
    if (rawDistance > 30.0) return 30.0;

    return rawDistance;
  }
}
