import '../../../../core/models/device.dart';

abstract class FinderState {
  const FinderState();
}

class FinderInitialState extends FinderState {
  const FinderInitialState();
}

class FinderScanningState extends FinderState {
  final bool isReversing;
  
  const FinderScanningState({this.isReversing = false});
}

class FinderResultsState extends FinderState {
  final List<Device> devices;
  
  const FinderResultsState(this.devices);
}

class FinderErrorState extends FinderState {
  final String message;
  
  const FinderErrorState(this.message);
} 