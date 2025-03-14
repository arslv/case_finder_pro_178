import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/device/device_interface.dart';
import '../../domain/repositories/device_repository.dart';

// Events
abstract class FinderEvent extends Equatable {
  const FinderEvent();

  @override
  List<Object?> get props => [];
}

class StartDiscovery extends FinderEvent {
  final String deviceName;

  const StartDiscovery(this.deviceName);

  @override
  List<Object?> get props => [deviceName];
}

class StopDiscovery extends FinderEvent {}

class ConnectToDevice extends FinderEvent {
  final Device device;

  const ConnectToDevice(this.device);

  @override
  List<Object?> get props => [device];
}

class DisconnectFromDevice extends FinderEvent {
  final Device device;

  const DisconnectFromDevice(this.device);

  @override
  List<Object?> get props => [device];
}

class DevicesUpdated extends FinderEvent {
  final List<Device> devices;

  const DevicesUpdated(this.devices);

  @override
  List<Object?> get props => [devices];
}

class DeviceStatusUpdated extends FinderEvent {
  final Device device;

  const DeviceStatusUpdated(this.device);

  @override
  List<Object?> get props => [device];
}

// States
abstract class FinderState extends Equatable {
  const FinderState();

  @override
  List<Object?> get props => [];
}

class FinderInitial extends FinderState {}

class FinderLoading extends FinderState {}

class FinderDiscovering extends FinderState {
  final List<Device> devices;
  final bool isConnecting;

  const FinderDiscovering(this.devices, {this.isConnecting = false});

  @override
  List<Object?> get props => [devices, isConnecting];

  FinderDiscovering copyWith({
    List<Device>? devices,
    bool? isConnecting,
  }) {
    return FinderDiscovering(
      devices ?? this.devices,
      isConnecting: isConnecting ?? this.isConnecting,
    );
  }
}

class FinderConnected extends FinderState {
  final Device device;
  final List<Device> allDevices;

  const FinderConnected(this.device, this.allDevices);

  @override
  List<Object?> get props => [device, allDevices];
}

class FinderError extends FinderState {
  final String message;

  const FinderError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class FinderBloc extends Bloc<FinderEvent, FinderState> {
  final DeviceRepository _deviceRepository;
  StreamSubscription? _devicesSubscription;
  StreamSubscription? _deviceStatusSubscription;
  List<Device> _currentDevices = [];

  FinderBloc(this._deviceRepository) : super(FinderInitial()) {
    on<StartDiscovery>(_onStartDiscovery);
    on<StopDiscovery>(_onStopDiscovery);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectFromDevice>(_onDisconnectFromDevice);
    on<DevicesUpdated>(_onDevicesUpdated);
    on<DeviceStatusUpdated>(_onDeviceStatusUpdated);

    // Подписываемся на обновления списка устройств
    _devicesSubscription = _deviceRepository.devicesStream.listen((devices) {
      add(DevicesUpdated(devices));
    });

    // Подписываемся на обновления статуса устройств
    _deviceStatusSubscription = _deviceRepository.deviceStatusStream.listen((device) {
      add(DeviceStatusUpdated(device));
    });
  }

  Future<void> _onStartDiscovery(StartDiscovery event, Emitter<FinderState> emit) async {
    try {
      emit(FinderLoading());
      
      // Проверяем поддержку Bluetooth/UWB
      final isSupported = await _deviceRepository.isSupported();
      if (!isSupported) {
        emit(const FinderError('Your device does not support Bluetooth or UWB'));
        return;
      }
      
      // Начинаем поиск устройств
      await _deviceRepository.startDiscovery(event.deviceName);
      
      // Обновляем состояние
      emit(FinderDiscovering(_currentDevices));
      
      // Вибрация для обратной связи
      HapticFeedback.mediumImpact();
    } catch (e) {
      emit(FinderError('Failed to start discovery: ${e.toString()}'));
    }
  }

  Future<void> _onStopDiscovery(StopDiscovery event, Emitter<FinderState> emit) async {
    try {
      await _deviceRepository.stopDiscovery();
      
      // Если мы подключены к устройству, сохраняем это состояние
      if (state is FinderConnected) {
        // Ничего не делаем, сохраняем текущее состояние
      } else {
        // Возвращаемся в начальное состояние
        emit(FinderInitial());
      }
      
      // Вибрация для обратной связи
      HapticFeedback.mediumImpact();
    } catch (e) {
      emit(FinderError('Failed to stop discovery: ${e.toString()}'));
    }
  }

  Future<void> _onConnectToDevice(ConnectToDevice event, Emitter<FinderState> emit) async {
    try {
      // Обновляем состояние, показывая, что подключаемся
      if (state is FinderDiscovering) {
        emit((state as FinderDiscovering).copyWith(isConnecting: true));
      }
      
      // Подключаемся к устройству
      await _deviceRepository.connectToDevice(event.device);
      
      // Вибрация для обратной связи
      HapticFeedback.mediumImpact();
      
      // Обновление состояния произойдет через DeviceStatusUpdated
    } catch (e) {
      // Возвращаемся к состоянию поиска в случае ошибки
      emit(FinderDiscovering(_currentDevices));
      
      // Показываем ошибку
      emit(FinderError('Failed to connect: ${e.toString()}'));
      
      // Возвращаемся к состоянию поиска после показа ошибки
      emit(FinderDiscovering(_currentDevices));
    }
  }

  Future<void> _onDisconnectFromDevice(DisconnectFromDevice event, Emitter<FinderState> emit) async {
    try {
      // Отключаемся от устройства
      await _deviceRepository.disconnectFromDevice(event.device);
      
      // Возвращаемся к состоянию поиска
      emit(FinderDiscovering(_currentDevices));
      
      // Вибрация для обратной связи
      HapticFeedback.mediumImpact();
    } catch (e) {
      emit(FinderError('Failed to disconnect: ${e.toString()}'));
      
      // Возвращаемся к предыдущему состоянию после показа ошибки
      if (state is FinderConnected) {
        emit(FinderConnected(event.device, _currentDevices));
      } else {
        emit(FinderDiscovering(_currentDevices));
      }
    }
  }

  void _onDevicesUpdated(DevicesUpdated event, Emitter<FinderState> emit) {
    _currentDevices = event.devices;
    
    // Обновляем состояние только если мы в режиме поиска
    if (state is FinderDiscovering) {
      emit(FinderDiscovering(_currentDevices, isConnecting: (state as FinderDiscovering).isConnecting));
    } else if (state is FinderConnected) {
      // Если мы подключены, обновляем список всех устройств
      final connectedDevice = (state as FinderConnected).device;
      emit(FinderConnected(connectedDevice, _currentDevices));
    }
  }

  void _onDeviceStatusUpdated(DeviceStatusUpdated event, Emitter<FinderState> emit) {
    final device = event.device;
    
    // Обновляем устройство в списке
    final index = _currentDevices.indexWhere((d) => d.id == device.id);
    if (index >= 0) {
      _currentDevices[index] = device;
    } else {
      _currentDevices.add(device);
    }
    
    // Обновляем состояние в зависимости от статуса устройства
    if (device.status == ConnectionStatus.connected || 
        device.status == ConnectionStatus.ranging) {
      emit(FinderConnected(device, _currentDevices));
    } else if (state is FinderConnected && (state as FinderConnected).device.id == device.id) {
      // Если мы были подключены к этому устройству, но оно отключилось
      emit(FinderDiscovering(_currentDevices));
    }
  }

  @override
  Future<void> close() {
    _devicesSubscription?.cancel();
    _deviceStatusSubscription?.cancel();
    return super.close();
  }
} 