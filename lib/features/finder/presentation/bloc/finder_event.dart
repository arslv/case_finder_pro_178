import '../../../../core/models/device.dart';
import 'package:equatable/equatable.dart';

abstract class FinderEvent extends Equatable {
  const FinderEvent();

  @override
  List<Object?> get props => [];
}

class StartScanningEvent extends FinderEvent {
  const StartScanningEvent();
}

class StopScanningEvent extends FinderEvent {
  const StopScanningEvent();
}

class DevicesUpdatedEvent extends FinderEvent {
  final List<Device> devices;
  
  const DevicesUpdatedEvent(this.devices);

  @override
  List<Object?> get props => [devices];
}

class ScanningErrorEvent extends FinderEvent {
  final String message;
  
  const ScanningErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class ScanningTimeoutEvent extends FinderEvent {
  final bool noDevicesFound;
  
  const ScanningTimeoutEvent({this.noDevicesFound = false});

  @override
  List<Object?> get props => [noDevicesFound];
}

class ShowResultsEvent extends FinderEvent {
  const ShowResultsEvent();
}

class AnimationReverseCompletedEvent extends FinderEvent {
  const AnimationReverseCompletedEvent();
}

class ClearErrorEvent extends FinderEvent {
  const ClearErrorEvent();
}

class ShowHelpEvent extends FinderEvent {
  const ShowHelpEvent();
}

class HideHelpEvent extends FinderEvent {
  const HideHelpEvent();
}

class TrackDeviceEvent extends FinderEvent {
  final Device device;

  const TrackDeviceEvent(this.device);

  @override
  List<Object?> get props => [device];
}

class StopTrackingEvent extends FinderEvent {
  const StopTrackingEvent();

  @override
  List<Object?> get props => [];
} 