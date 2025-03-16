import '../../../../core/models/device.dart';

abstract class FinderEvent {
  const FinderEvent();
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
}

class ScanningErrorEvent extends FinderEvent {
  final String message;
  
  const ScanningErrorEvent(this.message);
}

class ScanningTimeoutEvent extends FinderEvent {
  final bool noDevicesFound;
  
  const ScanningTimeoutEvent({required this.noDevicesFound});
}

class AnimationReverseCompletedEvent extends FinderEvent {
  const AnimationReverseCompletedEvent();
} 