import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/device_discovery/device_discovery_manager.dart';
import '../../../../core/models/device.dart';
import 'case_finder_event.dart';
import 'case_finder_state.dart';

class CaseFinderBloc extends Bloc<CaseFinderEvent, CaseFinderState> {
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
  
  CaseFinderBloc({DeviceDiscoveryManager? discoveryManager}) 
      : _discoveryManager = discoveryManager ?? DeviceDiscoveryManager(),
        super(const CaseFinderInitialState()) {
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
    Emitter<CaseFinderState> emit
  ) async {
    _errorMessage = null;
    
    emit(const CaseFinderScanningState());
    _pendingDevices = [];
    _hasFoundDevices = false;
    _scanStartTime = DateTime.now();
    
    try {
      final isSupported = await _discoveryManager.isSupported();
      
      if (!isSupported) {
        _errorMessage = 'Bluetooth is not available on this device';
        emit(const CaseFinderInitialState(showError: true));
        return;
      }
      
      _devicesSubscription = _discoveryManager.devicesStream.listen(
        (devices) => add(DevicesUpdatedEvent(_filterAirPodDevices(devices))),
        onError: (error) => add(ScanningErrorEvent(error.toString())),
      );
      
      await _discoveryManager.startDiscovery();
      
      _setupTimers();
      
    } catch (e) {
      _errorMessage = 'Failed to start scanning: ${e.toString()}';
      emit(const CaseFinderInitialState(showError: true));
    }
  }
  
  List<Device> _filterAirPodDevices(List<Device> devices) {
    return devices.where((device) {
      final name = device.name.toLowerCase();
      return name.contains('airpods') || 
             name.contains('pods') || 
             name.contains('max');
    }).toList();
  }
  
  Future<void> _onStopScanning(
    StopScanningEvent event, 
    Emitter<CaseFinderState> emit
  ) async {
    _cancelTimers();
    
    if (state is CaseFinderScanningState) {
      emit(const CaseFinderScanningState(isReversing: true));
    } else {
      await _cleanupScanning();
      emit(const CaseFinderInitialState());
    }
  }
  
  void _onAnimationReverseCompleted(
    AnimationReverseCompletedEvent event,
    Emitter<CaseFinderState> emit
  ) async {
    await _cleanupScanning();
    emit(const CaseFinderInitialState());
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
    Emitter<CaseFinderState> emit
  ) {
    if (event.devices.isNotEmpty) {
      _hasFoundDevices = true;
      _pendingDevices = event.devices;
      
      _shortTimeoutTimer?.cancel();
      _shortTimeoutTimer = null;
      
      // Check if minimum scanning time has passed
      if (_canShowResults()) {
        emit(CaseFinderResultsState(_pendingDevices));
      }
      // Otherwise, keep in scanning state and wait for minimum time
    } else if (state is! CaseFinderScanningState) {
      emit(const CaseFinderScanningState());
    }
  }
  
  bool _canShowResults() {
    if (_scanStartTime == null) return true;
    
    final elapsedSeconds = DateTime.now().difference(_scanStartTime!).inSeconds;
    return elapsedSeconds >= _minScanningSeconds;
  }
  
  void _onShowResults(
    ShowResultsEvent event,
    Emitter<CaseFinderState> emit
  ) {
    if (_hasFoundDevices && _pendingDevices.isNotEmpty) {
      emit(CaseFinderResultsState(_pendingDevices));
    }
  }
  
  void _onScanningError(
    ScanningErrorEvent event, 
    Emitter<CaseFinderState> emit
  ) {
    _cancelTimers();
    _cleanupScanning();
    
    // Set error message and return to initial state with error flag
    _errorMessage = event.message;
    emit(const CaseFinderInitialState(showError: true));
  }
  
  void _onScanningTimeout(
    ScanningTimeoutEvent event, 
    Emitter<CaseFinderState> emit
  ) async {
    await _cleanupScanning();
    
    if (event.noDevicesFound) {
      // Set error message and return to initial state with error flag
      _errorMessage = 'No AirPods or similar devices found';
      emit(const CaseFinderInitialState(showError: true));
    } else if (_hasFoundDevices) {
      // If we have found devices, show them
      emit(CaseFinderResultsState(_pendingDevices));
    } else {
      // Set error message and return to initial state with error flag
      _errorMessage = 'Scanning timed out. Please try again.';
      emit(const CaseFinderInitialState(showError: true));
    }
  }
  
  void _onClearError(
    ClearErrorEvent event,
    Emitter<CaseFinderState> emit
  ) {
    _errorMessage = null;
    if (state is CaseFinderInitialState) {
      emit(const CaseFinderInitialState());
    }
  }
  
  void _onShowHelp(
    ShowHelpEvent event,
    Emitter<CaseFinderState> emit
  ) {
    if (state is CaseFinderInitialState) {
      emit(const CaseFinderInitialState(showHelp: true));
    } else if (state is CaseFinderResultsState) {
      final currentState = state as CaseFinderResultsState;
      emit(CaseFinderResultsState(currentState.devices, showHelp: true));
    }
  }
  
  void _onHideHelp(
    HideHelpEvent event,
    Emitter<CaseFinderState> emit
  ) {
    if (state is CaseFinderInitialState) {
      emit(const CaseFinderInitialState());
    } else if (state is CaseFinderResultsState) {
      final currentState = state as CaseFinderResultsState;
      emit(CaseFinderResultsState(currentState.devices));
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