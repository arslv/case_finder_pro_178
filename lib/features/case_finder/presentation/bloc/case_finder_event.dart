import '../../../../core/models/device.dart';
import 'package:equatable/equatable.dart';

abstract class CaseFinderEvent extends Equatable {
  const CaseFinderEvent();

  @override
  List<Object?> get props => [];
}

class StartScanningEvent extends CaseFinderEvent {
  const StartScanningEvent();
}

class StopScanningEvent extends CaseFinderEvent {
  const StopScanningEvent();
}

class DevicesUpdatedEvent extends CaseFinderEvent {
  final List<Device> devices;
  
  const DevicesUpdatedEvent(this.devices);

  @override
  List<Object?> get props => [devices];
}

class ScanningErrorEvent extends CaseFinderEvent {
  final String message;
  
  const ScanningErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class ScanningTimeoutEvent extends CaseFinderEvent {
  final bool noDevicesFound;
  
  const ScanningTimeoutEvent({this.noDevicesFound = false});

  @override
  List<Object?> get props => [noDevicesFound];
}

class ShowResultsEvent extends CaseFinderEvent {
  const ShowResultsEvent();
}

class AnimationReverseCompletedEvent extends CaseFinderEvent {
  const AnimationReverseCompletedEvent();
}

class ClearErrorEvent extends CaseFinderEvent {
  const ClearErrorEvent();
}

class ShowHelpEvent extends CaseFinderEvent {
  const ShowHelpEvent();
}

class HideHelpEvent extends CaseFinderEvent {
  const HideHelpEvent();
}

class TrackDeviceEvent extends CaseFinderEvent {
  final Device device;

  const TrackDeviceEvent(this.device);

  @override
  List<Object?> get props => [device];
}

class StopTrackingEvent extends CaseFinderEvent {
  const StopTrackingEvent();

  @override
  List<Object?> get props => [];
} 