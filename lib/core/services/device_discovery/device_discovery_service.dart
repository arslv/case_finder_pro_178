import 'dart:async';
import '../../models/device.dart';

abstract class DeviceDiscoveryService {
  /// Проверяет, поддерживается ли данный тип обнаружения устройств
  Future<bool> isSupported();
  
  /// Запускает поиск устройств
  Future<void> startDiscovery();
  
  /// Останавливает поиск устройств
  Future<void> stopDiscovery();
  
  /// Поток обнаруженных устройств
  Stream<List<Device>> get devicesStream;
  
  /// Освобождает ресурсы
  Future<void> dispose();
} 