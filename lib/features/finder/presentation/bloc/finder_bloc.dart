import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/device_discovery/device_discovery_manager.dart';
import '../../../../core/models/device.dart';
import 'finder_event.dart';
import 'finder_state.dart';

class FinderBloc extends Bloc<FinderEvent, FinderState> {
  final DeviceDiscoveryManager _discoveryManager;
  StreamSubscription? _devicesSubscription;
  Timer? _shortTimeoutTimer;
  Timer? _longTimeoutTimer;
  Timer? _minScanningTimer;
  
  static const int _shortTimeoutSeconds = 15;
  static const int _longTimeoutSeconds = 30;
  static const int _minScanningSeconds = 10;
  
  List<Device> _pendingDevices = [];
  bool _hasFoundDevices = false;
  DateTime? _scanStartTime;
  
  String? _errorMessage;
  
  String? get errorMessage => _errorMessage;
  
  FinderBloc({DeviceDiscoveryManager? discoveryManager}) 
      : _discoveryManager = discoveryManager ?? DeviceDiscoveryManager(),
        super(const FinderInitialState()) {
    on<StartScanningEvent>(_onStartScanning);
    on<StopScanningEvent>(_onStopScanning);
    on<DevicesUpdatedEvent>(_onDevicesUpdated);
    on<ScanningErrorEvent>(_onScanningError);
    on<ScanningTimeoutEvent>(_onScanningTimeout);
    on<AnimationReverseCompletedEvent>(_onAnimationReverseCompleted);
    on<ShowResultsEvent>(_onShowResults);
    on<ClearErrorEvent>(_onClearError);
    on<ShowHelpEvent>(_onShowHelp);
    on<HideHelpEvent>(_onHideHelp);
  }
  
  Future<void> _onStartScanning(
    StartScanningEvent event, 
    Emitter<FinderState> emit
  ) async {
    _errorMessage = null;
    
    emit(const FinderScanningState());
    _pendingDevices = [];
    _hasFoundDevices = false;
    _scanStartTime = DateTime.now();
    
    try {
      final isSupported = await _discoveryManager.isSupported();
      
      if (!isSupported) {
        _errorMessage = 'Bluetooth is not available on this device';
        emit(const FinderInitialState(showError: true));
        return;
      }
      
      _devicesSubscription = _discoveryManager.devicesStream.listen(
        (devices) => add(DevicesUpdatedEvent(devices)),
        onError: (error) => add(ScanningErrorEvent(error.toString())),
      );
      
      await _discoveryManager.startDiscovery();
      
      _setupTimers();
      
    } catch (e) {
      _errorMessage = 'Failed to start scanning: ${e.toString()}';
      emit(const FinderInitialState(showError: true));
    }
  }
  
  Future<void> _onStopScanning(
    StopScanningEvent event, 
    Emitter<FinderState> emit
  ) async {
    _cancelTimers();
    
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
      final hasActiveSubscription = _devicesSubscription != null;
      
      if (hasActiveSubscription) {
        await _devicesSubscription?.cancel();
        _devicesSubscription = null;
        
        await _discoveryManager.stopDiscovery();
      }
    } catch (e) {
      print('Cleanup scanning error: $e');
    }
  }
  
  void _onDevicesUpdated(
    DevicesUpdatedEvent event, 
    Emitter<FinderState> emit
  ) {
    if (event.devices.isNotEmpty) {
      _hasFoundDevices = true;
      _pendingDevices = event.devices;
      
      _shortTimeoutTimer?.cancel();
      _shortTimeoutTimer = null;
      
      // Check if minimum scanning time has passed
      if (_canShowResults()) {
        emit(FinderResultsState(_pendingDevices));
      }
      // Otherwise, keep in scanning state and wait for minimum time
    } else if (state is! FinderScanningState) {
      emit(const FinderScanningState());
    }
  }
  
  bool _canShowResults() {
    if (_scanStartTime == null) return true;
    
    final elapsedSeconds = DateTime.now().difference(_scanStartTime!).inSeconds;
    return elapsedSeconds >= _minScanningSeconds;
  }
  
  void _onShowResults(
    ShowResultsEvent event,
    Emitter<FinderState> emit
  ) {
    if (_hasFoundDevices && _pendingDevices.isNotEmpty) {
      emit(FinderResultsState(_pendingDevices));
    }
  }
  
  void _onScanningError(
    ScanningErrorEvent event, 
    Emitter<FinderState> emit
  ) {
    _cancelTimers();
    _cleanupScanning();
    
    // Set error message and return to initial state with error flag
    _errorMessage = event.message;
    emit(const FinderInitialState(showError: true));
  }
  
  void _onScanningTimeout(
    ScanningTimeoutEvent event, 
    Emitter<FinderState> emit
  ) async {
    await _cleanupScanning();
    
    if (event.noDevicesFound) {
      // Set error message and return to initial state with error flag
      _errorMessage = 'Nothing found';
      emit(const FinderInitialState(showError: true));
    } else if (_hasFoundDevices) {
      // If we have found devices, show them
      emit(FinderResultsState(_pendingDevices));
    } else {
      // Set error message and return to initial state with error flag
      _errorMessage = 'Scanning timed out. Please try again.';
      emit(const FinderInitialState(showError: true));
    }
  }
  
  void _onClearError(
    ClearErrorEvent event,
    Emitter<FinderState> emit
  ) {
    _errorMessage = null;
    if (state is FinderInitialState) {
      emit(const FinderInitialState());
    }
  }
  
  void _onShowHelp(
    ShowHelpEvent event,
    Emitter<FinderState> emit
  ) {
    if (state is FinderInitialState) {
      emit(const FinderInitialState(showHelp: true));
    } else if (state is FinderResultsState) {
      final currentState = state as FinderResultsState;
      emit(FinderResultsState(currentState.devices, showHelp: true));
    }
  }
  
  void _onHideHelp(
    HideHelpEvent event,
    Emitter<FinderState> emit
  ) {
    if (state is FinderInitialState) {
      emit(const FinderInitialState());
    } else if (state is FinderResultsState) {
      final currentState = state as FinderResultsState;
      emit(FinderResultsState(currentState.devices));
    }
  }
  
  void _setupTimers() {
    _cancelTimers();
    
    // Minimum scanning time (10 seconds) - ensures animation plays for at least this long
    _minScanningTimer = Timer(Duration(seconds: _minScanningSeconds), () {
      if (_hasFoundDevices && _pendingDevices.isNotEmpty) {
        add(const ShowResultsEvent());
      }
    });
    
    // Short timeout (15 seconds) - checks if at least one device is found
    _shortTimeoutTimer = Timer(Duration(seconds: _shortTimeoutSeconds), () {
      if (!_hasFoundDevices) {
        add(const ScanningTimeoutEvent(noDevicesFound: true));
      }
    });
    
    // Long timeout (30 seconds) - ends scanning in any case
    _longTimeoutTimer = Timer(Duration(seconds: _longTimeoutSeconds), () {
      add(const ScanningTimeoutEvent(noDevicesFound: false));
    });
  }
  
  void _cancelTimers() {
    _minScanningTimer?.cancel();
    _minScanningTimer = null;
    _shortTimeoutTimer?.cancel();
    _shortTimeoutTimer = null;
    _longTimeoutTimer?.cancel();
    _longTimeoutTimer = null;
  }
  
  @override
  Future<void> close() async {
    _cancelTimers();
    await _cleanupScanning();
    return super.close();
  }
} 