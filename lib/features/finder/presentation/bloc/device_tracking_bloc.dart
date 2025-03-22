import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/device.dart';
import '../../../../core/services/device_tracking/device_tracking_service.dart';
import '../../domain/repositories/device_tracking_repository.dart';

// Events
abstract class DeviceTrackingEvent extends Equatable {
  const DeviceTrackingEvent();

  @override
  List<Object?> get props => [];
  
  @override
  String toString() => runtimeType.toString();
}

class StartTrackingEvent extends DeviceTrackingEvent {
  final Device device;

  const StartTrackingEvent(this.device);

  @override
  List<Object?> get props => [device];
  
  @override
  String toString() => 'StartTrackingEvent(${device.name})';
}

class StopTrackingEvent extends DeviceTrackingEvent {
  const StopTrackingEvent();
}

class TrackingUpdateEvent extends DeviceTrackingEvent {
  final DeviceTrackingResult result;

  const TrackingUpdateEvent(this.result);

  @override
  List<Object?> get props => [result];
  
  @override
  String toString() => 'TrackingUpdateEvent(${result.distance.toStringAsFixed(2)}m)';
}

// States
abstract class DeviceTrackingState extends Equatable {
  const DeviceTrackingState();

  @override
  List<Object?> get props => [];
  
  @override
  String toString() => runtimeType.toString();
}

class DeviceTrackingInitial extends DeviceTrackingState {
  const DeviceTrackingInitial();
}

class DeviceTrackingInProgress extends DeviceTrackingState {
  final Device device;
  final double distance;
  final TrackingState trackingState;
  final DateTime lastUpdate;

  const DeviceTrackingInProgress({
    required this.device,
    required this.distance,
    required this.trackingState,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props => [device, distance, trackingState, lastUpdate];
  
  @override
  String toString() => 'DeviceTrackingInProgress(${device.name}, ${distance.toStringAsFixed(2)}m, $trackingState)';

  DeviceTrackingInProgress copyWith({
    Device? device,
    double? distance,
    TrackingState? trackingState,
    DateTime? lastUpdate,
  }) {
    return DeviceTrackingInProgress(
      device: device ?? this.device,
      distance: distance ?? this.distance,
      trackingState: trackingState ?? this.trackingState,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

class DeviceTrackingError extends DeviceTrackingState {
  final String message;

  const DeviceTrackingError(this.message);

  @override
  List<Object?> get props => [message];
  
  @override
  String toString() => 'DeviceTrackingError($message)';
}

// BLoC
class DeviceTrackingBloc extends Bloc<DeviceTrackingEvent, DeviceTrackingState> {
  final DeviceTrackingRepository _repository;
  StreamSubscription? _trackingSubscription;
  Timer? _updateTimer;

  DeviceTrackingBloc({DeviceTrackingRepository? repository})
      : _repository = repository ?? DeviceTrackingRepository(),
        super(const DeviceTrackingInitial()) {
    on<StartTrackingEvent>(_onStartTracking);
    on<StopTrackingEvent>(_onStopTracking);
    on<TrackingUpdateEvent>(_onTrackingUpdate);
  }

  Future<void> _onStartTracking(
    StartTrackingEvent event,
    Emitter<DeviceTrackingState> emit,
  ) async {
    await _trackingSubscription?.cancel();
    _updateTimer?.cancel();

    final success = await _repository.startTracking(event.device);

    if (success) {
      // Initial state with the device's current distance if available
      final initialDistance = event.device.distance ?? 10.0;
      final initialState = _determineTrackingState(initialDistance);
      
      emit(DeviceTrackingInProgress(
        device: event.device,
        distance: initialDistance,
        trackingState: initialState,
        lastUpdate: DateTime.now(),
      ));

      // Subscribe to tracking updates
      _trackingSubscription = _repository.trackingStream.listen(
        (result) {
          debugPrint('Bloc received tracking update: $result');
          add(TrackingUpdateEvent(result));
        },
        onError: (error) {
          debugPrint('Error in tracking stream: $error');
          emit(DeviceTrackingError(error.toString()));
        },
      );
      
      // Set up a timer to ensure we're getting updates
      // This is a fallback in case the Bluetooth scanning doesn't work properly
      _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (state is DeviceTrackingInProgress) {
          final currentState = state as DeviceTrackingInProgress;
          final timeSinceLastUpdate = DateTime.now().difference(currentState.lastUpdate).inSeconds;
          
          if (timeSinceLastUpdate > 4) {
            // Restart tracking
            _repository.stopTracking().then((_) {
              _repository.startTracking(currentState.device);
            });
          }
        }
      });
    } else {
      emit(const DeviceTrackingError('Failed to start device tracking'));
    }
  }

  Future<void> _onStopTracking(
    StopTrackingEvent event,
    Emitter<DeviceTrackingState> emit,
  ) async {
    _updateTimer?.cancel();
    _updateTimer = null;
    await _trackingSubscription?.cancel();
    _trackingSubscription = null;
    await _repository.stopTracking();
    emit(const DeviceTrackingInitial());
  }

  void _onTrackingUpdate(
    TrackingUpdateEvent event,
    Emitter<DeviceTrackingState> emit,
  ) {
    if (state is DeviceTrackingInProgress) {
      final currentState = state as DeviceTrackingInProgress;
      
      final newState = currentState.copyWith(
        distance: event.result.distance,
        trackingState: event.result.state,
        lastUpdate: event.result.timestamp,
      );
      
      // Only log significant distance changes
      if ((currentState.distance - newState.distance).abs() > 0.1 || 
          currentState.trackingState != newState.trackingState) {
      }
      
      emit(newState);
    }
  }

  TrackingState _determineTrackingState(double distance) {
    if (distance <= 0.5) {
      return TrackingState.close;
    } else if (distance <= 2.0) {
      return TrackingState.nearby;
    } else {
      return TrackingState.far;
    }
  }

  @override
  Future<void> close() async {
    _updateTimer?.cancel();
    await _trackingSubscription?.cancel();
    await _repository.stopTracking();
    return super.close();
  }
} 