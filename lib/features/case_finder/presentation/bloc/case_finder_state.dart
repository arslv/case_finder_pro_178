import '../../../../core/models/device.dart';

abstract class CaseFinderState {
  const CaseFinderState();
}

class CaseFinderInitialState extends CaseFinderState {
  final bool showError;
  final bool showHelp;
  
  const CaseFinderInitialState({
    this.showError = false,
    this.showHelp = false,
  });
}

class CaseFinderScanningState extends CaseFinderState {
  final bool isReversing;
  
  const CaseFinderScanningState({this.isReversing = false});
}

class CaseFinderResultsState extends CaseFinderState {
  final List<Device> devices;
  final bool showHelp;
  
  const CaseFinderResultsState(
    this.devices, {
    this.showHelp = false,
  });
}

// This state is kept for backward compatibility but will not be used directly
class CaseFinderErrorState extends CaseFinderState {
  final String message;
  
  const CaseFinderErrorState(this.message);
} 