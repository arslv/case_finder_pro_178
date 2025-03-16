import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../services/bluetooth_service.dart';

class BluetoothScannerScreen extends StatefulWidget {
  const BluetoothScannerScreen({Key? key}) : super(key: key);

  @override
  _BluetoothScannerScreenState createState() => _BluetoothScannerScreenState();
}

class _BluetoothScannerScreenState extends State<BluetoothScannerScreen> {
  final AppBluetoothService _bluetoothService = AppBluetoothService();

  @override
  void initState() {
    super.initState();
    _initializeBluetoothService();
  }

  Future<void> _initializeBluetoothService() async {
    await _bluetoothService.initialize();
    _startScan();
  }

  Future<void> _startScan() async {
    try {
      await _bluetoothService.startScan();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  void dispose() {
    _bluetoothService.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Scanner'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _bluetoothService.stopScan();
          await _startScan();
        },
        child: StreamBuilder<List<ScanResult>>(
          stream: _bluetoothService.devicesStream,
          initialData: const [],
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                    'Устройства не найдены. Потяните вниз для обновления.'),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                ScanResult result = snapshot.data![index];
                return ListTile(
                  title: Text(
                    result.device.platformName.isNotEmpty
                        ? result.device.platformName
                        : 'Unnamed Device',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: result.device.platformName.isNotEmpty
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${result.device.remoteId}'),
                      Text('RSSI: ${result.rssi} dBm'),
                      Text(
                          'Расстояние: ~${_bluetoothService.calculateDistance(result.rssi).toStringAsFixed(1)} м'),
                      if (_bluetoothService.isAppleDevice(result))
                        const Text('Apple Device',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: _buildSignalStrengthIcon(result.rssi),
                  onTap: () {
                    // Действие при нажатии на устройство
                    print('Выбрано устройство: ${result.device.platformName}');
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: Stream.value(_bluetoothService.isScanning),
        initialData: false,
        builder: (context, snapshot) {
          final isScanning = snapshot.data ?? false;
          return FloatingActionButton(
            onPressed: isScanning ? _bluetoothService.stopScan : _startScan,
            child: Icon(isScanning ? Icons.stop : Icons.search),
            tooltip:
                isScanning ? 'Остановить сканирование' : 'Начать сканирование',
          );
        },
      ),
    );
  }

  // Иконка силы сигнала
  Widget _buildSignalStrengthIcon(int rssi) {
    IconData iconData;
    Color color;

    if (rssi >= -60) {
      iconData = Icons.signal_cellular_4_bar;
      color = Colors.green;
    } else if (rssi >= -70) {
      iconData = Icons.signal_cellular_alt;
      color = Colors.lightGreen;
    } else if (rssi >= -80) {
      iconData = Icons.signal_cellular_alt_2_bar;
      color = Colors.orange;
    } else if (rssi >= -90) {
      iconData = Icons.signal_cellular_alt_1_bar;
      color = Colors.orangeAccent;
    } else {
      iconData = Icons.signal_cellular_0_bar;
      color = Colors.red;
    }

    return Icon(iconData, color: color);
  }
}
