// import 'dart:async';
// import 'package:uwb/flutter_uwb.dart';
// import 'device_interface.dart';
//
// class UwbService implements DeviceInterface {
//   final Uwb _uwb = Uwb();
//   final _devicesController = StreamController<List<Device>>.broadcast();
//   final _deviceStatusController = StreamController<Device>.broadcast();
//   final Map<String, Device> _discoveredDevices = {};
//
//   UwbService() {
//     _setupListeners();
//   }
//
//   void _setupListeners() {
//     // Слушаем события обнаружения устройств
//     _uwb.discoveryStateStream.listen((event) {
//       print('UWB Discovery event: $event');
//       if (event is UwbDevice) {
//         final device = _mapUwbDeviceToDevice(event);
//         _updateDevice(device);
//       }
//     });
//
//     // Слушаем события сессии UWB
//     _uwb.uwbSessionStateStream.listen((event) {
//       print('UWB Session event: $event');
//     });
//
//     // Слушаем данные UWB (расстояние и т.д.)
//     _uwb.uwbDataStream.listen((devices) {
//       print('UWB Data event: $devices');
//       for (final uwbDevice in devices) {
//         if (uwbDevice is UwbDevice) {
//           final device = _mapUwbDeviceToDevice(uwbDevice);
//           _updateDevice(device);
//         }
//       }
//     });
//   }
//
//   void _updateDevice(Device device) {
//     _discoveredDevices[device.id] = device;
//     _devicesController.add(_discoveredDevices.values.toList());
//     _deviceStatusController.add(device);
//   }
//
//   Device _mapUwbDeviceToDevice(UwbDevice uwbDevice) {
//     // Определяем статус на основе состояния UWB устройства
//     ConnectionStatus status = ConnectionStatus.disconnected;
//     if (uwbDevice.state == DeviceState.connected) {
//       status = ConnectionStatus.connected;
//     } else if (uwbDevice.state == DeviceState.ranging) {
//       status = ConnectionStatus.ranging;
//     }
//
//     // Определяем тип устройства
//     DeviceType type = DeviceType.other;
//
//     return Device(
//       id: uwbDevice.id ?? '',
//       name: uwbDevice.name ?? 'Unknown Device',
//       type: type,
//       status: status,
//       distance: uwbDevice.distance,
//     );
//   }
//
//   @override
//   Future<bool> isSupported() async {
//     try {
//       return await _uwb.isUwbSupported();
//     } catch (e) {
//       print('UWB support check error: $e');
//       return false;
//     }
//   }
//
//   @override
//   Future<void> startDiscovery(String deviceName) async {
//     try {
//       print('Starting UWB discovery with name: $deviceName');
//       await _uwb.discoverDevices(deviceName);
//     } catch (e) {
//       print('UWB discovery error: $e');
//       rethrow;
//     }
//   }
//
//   @override
//   Future<void> stopDiscovery() async {
//     try {
//       print('Stopping UWB discovery');
//       await _uwb.stopDiscovery();
//       _discoveredDevices.clear();
//       _devicesController.add([]);
//     } catch (e) {
//       print('UWB stop discovery error: $e');
//       rethrow;
//     }
//   }
//
//   @override
//   Future<void> connect(Device device) async {
//     try {
//       print('Connecting to UWB device: ${device.id}');
//
//       // Создаем UWB устройство для подключения
//       final uwbDevice = UwbDevice(
//         id: device.id,
//         name: device.name,
//         deviceType: DeviceType.smartphone,
//         state: DeviceState.disconnected,
//       );
//
//       await _uwb.startRanging(uwbDevice);
//     } catch (e) {
//       print('UWB connect error: $e');
//       rethrow;
//     }
//   }
//
//   @override
//   Future<void> disconnect(Device device) async {
//     try {
//       print('Disconnecting from UWB device: ${device.id}');
//
//       // Создаем UWB устройство для отключения
//       final uwbDevice = UwbDevice(
//         id: device.id,
//         name: device.name,
//         deviceType: DeviceType.smartphone,
//         state: DeviceState.ranging,
//       );
//
//       await _uwb.stopRanging(uwbDevice);
//     } catch (e) {
//       print('UWB disconnect error: $e');
//       rethrow;
//     }
//   }
//
//   @override
//   Stream<List<Device>> get devicesStream => _devicesController.stream;
//
//   @override
//   Stream<Device> get deviceStatusStream => _deviceStatusController.stream;
//
//   void dispose() {
//     _devicesController.close();
//     _deviceStatusController.close();
//   }
// }