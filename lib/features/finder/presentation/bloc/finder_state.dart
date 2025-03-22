import '../../../../core/models/device.dart';

abstract class FinderState {
  const FinderState();
}

class FinderInitialState extends FinderState {
  final bool showError;
  final bool showHelp;
  
  const FinderInitialState({
    this.showError = false,
    this.showHelp = false,
  });
}

class FinderScanningState extends FinderState {
  final bool isReversing;
  
  const FinderScanningState({this.isReversing = false});
}

class FinderResultsState extends FinderState {
  final List<Device> devices;
  final bool showHelp;
  
  const FinderResultsState(
    this.devices, {
    this.showHelp = false,
  });
}

// This state is kept for backward compatibility but will not be used directly
class FinderErrorState extends FinderState {
  final String message;
  
  const FinderErrorState(this.message);
} 