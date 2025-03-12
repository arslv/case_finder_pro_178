import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pod_finder_pro_178/features/finder/domain/models/uwb_device.dart';

// Events
abstract class FinderEvent extends Equatable {
  const FinderEvent();

  @override
  List<Object?> get props => [];
}

class StartSearching extends FinderEvent {}

class StopSearching extends FinderEvent {}

class RefreshDevices extends FinderEvent {}

class DeviceFound extends FinderEvent {
  final UwbDevice device;

  const DeviceFound(this.device);

  @override
  List<Object?> get props => [device];
}

// States
abstract class FinderState extends Equatable {
  const FinderState();

  @override
  List<Object?> get props => [];
}

class FinderInitial extends FinderState {}

class FinderSearching extends FinderState {}

class FinderDevicesFound extends FinderState {
  final List<UwbDevice> devices;

  const FinderDevicesFound(this.devices);

  @override
  List<Object?> get props => [devices];
}

class FinderError extends FinderState {
  final String message;

  const FinderError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class FinderBloc extends Bloc<FinderEvent, FinderState> {
  final _uwbPlugin = Uwb();

  FinderBloc() : super(FinderInitial()) {
    on<StartSearching>(_onStartSearching);
    on<StopSearching>(_onStopSearching);
    on<RefreshDevices>(_onRefreshDevices);
    on<DeviceFound>(_onDeviceFound);
  }

  Future<void> _onStartSearching(StartSearching event, Emitter<FinderState> emit) async {
    emit(FinderSearching());
    try {
      await _uwbPlugin.discoverDevices("Your Device Name");
      
      _uwbPlugin.discoveryStateStream.listen((state) {
        if (state is uwb_package.DeviceFoundState) {
          print(state);
        }
      });
      
    } catch (e) {
      emit(FinderError(e.toString()));
    }
  }

  Future<void> _onStopSearching(StopSearching event, Emitter<FinderState> emit) async {
    await _uwbPlugin.stopDiscovery();
    emit(FinderInitial());
  }

  Future<void> _onRefreshDevices(RefreshDevices event, Emitter<FinderState> emit) async {
    emit(FinderSearching());
    await _uwbPlugin.stopDiscovery();
    await _uwbPlugin.discoverDevices("Your Device Name");
  }

  void _onDeviceFound(DeviceFound event, Emitter<FinderState> emit) {
    if (state is FinderDevicesFound) {
      final currentDevices = (state as FinderDevicesFound).devices;
      if (!currentDevices.contains(event.device)) {
        emit(FinderDevicesFound([...currentDevices, event.device]));
      }
    } else {
      emit(FinderDevicesFound([event.device]));
    }
  }

  @override
  Future<void> close() {
    _uwbPlugin.stopDiscovery();
    return super.close();
  }
}
