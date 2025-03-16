import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/device_discovery/device_discovery_manager.dart';
import 'finder_event.dart';
import 'finder_state.dart';

class FinderBloc extends Bloc<FinderEvent, FinderState> {
  final DeviceDiscoveryManager _discoveryManager;
  StreamSubscription? _devicesSubscription;
  Timer? _shortTimeoutTimer;
  Timer? _longTimeoutTimer;
  
  // Константы для таймаутов
  static const int _shortTimeoutSeconds = 15;
  static const int _longTimeoutSeconds = 30;
  
  FinderBloc({DeviceDiscoveryManager? discoveryManager}) 
      : _discoveryManager = discoveryManager ?? DeviceDiscoveryManager(),
        super(const FinderInitialState()) {
    on<StartScanningEvent>(_onStartScanning);
    on<StopScanningEvent>(_onStopScanning);
    on<DevicesUpdatedEvent>(_onDevicesUpdated);
    on<ScanningErrorEvent>(_onScanningError);
    on<ScanningTimeoutEvent>(_onScanningTimeout);
    on<AnimationReverseCompletedEvent>(_onAnimationReverseCompleted);
  }
  
  Future<void> _onStartScanning(
    StartScanningEvent event, 
    Emitter<FinderState> emit
  ) async {
    emit(const FinderScanningState());
    
    try {
      final isSupported = await _discoveryManager.isSupported();
      
      if (!isSupported) {
        emit(const FinderErrorState('Bluetooth is not available on this device'));
        return;
      }
      
      // Подписываемся на поток устройств
      _devicesSubscription = _discoveryManager.devicesStream.listen(
        (devices) => add(DevicesUpdatedEvent(devices)),
        onError: (error) => add(ScanningErrorEvent(error.toString())),
      );
      
      // Запускаем обнаружение устройств
      await _discoveryManager.startDiscovery();
      
      // Устанавливаем таймеры
      _setupTimers();
      
    } catch (e) {
      emit(FinderErrorState('Failed to start scanning: ${e.toString()}'));
    }
  }
  
  Future<void> _onStopScanning(
    StopScanningEvent event, 
    Emitter<FinderState> emit
  ) async {
    _cancelTimers();
    
    // Сначала запускаем обратную анимацию
    if (state is FinderScanningState) {
      emit(const FinderScanningState(isReversing: true));
    } else {
      await _cleanupScanning();
      emit(const FinderInitialState());
    }
  }
  
  void _onAnimationReverseCompleted(
    AnimationReverseCompletedEvent event,
    Emitter<FinderState> emit
  ) async {
    await _cleanupScanning();
    emit(const FinderInitialState());
  }
  
  Future<void> _cleanupScanning() async {
    try {
      await _discoveryManager.stopDiscovery();
      await _devicesSubscription?.cancel();
      _devicesSubscription = null;
    } catch (e) {
      // Игнорируем ошибки при очистке
    }
  }
  
  void _onDevicesUpdated(
    DevicesUpdatedEvent event, 
    Emitter<FinderState> emit
  ) {
    if (event.devices.isNotEmpty) {
      // Если найден хотя бы один девайс, отменяем короткий таймаут
      _shortTimeoutTimer?.cancel();
      _shortTimeoutTimer = null;
      
      emit(FinderResultsState(event.devices));
    } else if (state is! FinderScanningState) {
      emit(const FinderScanningState());
    }
  }
  
  void _onScanningError(
    ScanningErrorEvent event, 
    Emitter<FinderState> emit
  ) {
    _cancelTimers();
    _cleanupScanning();
    emit(FinderErrorState(event.message));
  }
  
  void _onScanningTimeout(
    ScanningTimeoutEvent event, 
    Emitter<FinderState> emit
  ) async {
    await _cleanupScanning();
    
    if (event.noDevicesFound) {
      emit(const FinderErrorState('No devices found. Please try again.'));
    } else if (state is FinderResultsState) {
      // Если уже есть результаты, оставляем их
    } else {
      emit(const FinderErrorState('Scanning timed out. Please try again.'));
    }
  }
  
  void _setupTimers() {
    _cancelTimers();
    
    // Короткий таймаут (15 секунд) - проверяет, найден ли хотя бы один девайс
    _shortTimeoutTimer = Timer(Duration(seconds: _shortTimeoutSeconds), () {
      if (state is FinderScanningState || (state is FinderResultsState && (state as FinderResultsState).devices.isEmpty)) {
        add(const ScanningTimeoutEvent(noDevicesFound: true));
      }
    });
    
    // Длинный таймаут (30 секунд) - в любом случае завершает сканирование
    _longTimeoutTimer = Timer(Duration(seconds: _longTimeoutSeconds), () {
      add(const ScanningTimeoutEvent(noDevicesFound: false));
    });
  }
  
  void _cancelTimers() {
    _shortTimeoutTimer?.cancel();
    _shortTimeoutTimer = null;
    _longTimeoutTimer?.cancel();
    _longTimeoutTimer = null;
  }
  
  @override
  Future<void> close() async {
    _cancelTimers();
    await _devicesSubscription?.cancel();
    await _discoveryManager.dispose();
    return super.close();
  }
} 