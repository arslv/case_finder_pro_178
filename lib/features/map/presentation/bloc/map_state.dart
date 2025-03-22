import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/models/favorite_device.dart';

abstract class MapState extends Equatable {
  const MapState();
  
  @override
  List<Object?> get props => [];
}

class MapInitialState extends MapState {
  const MapInitialState();
}

class MapLoadingState extends MapState {
  const MapLoadingState();
}

class MapLoadedState extends MapState {
  final Position currentPosition;
  final List<FavoriteDevice> favoriteDevices;
  final bool shouldCenter;
  
  const MapLoadedState({
    required this.currentPosition,
    required this.favoriteDevices,
    this.shouldCenter = false,
  });
  
  @override
  List<Object?> get props => [currentPosition, favoriteDevices, shouldCenter];
  
  MapLoadedState copyWith({
    Position? currentPosition,
    List<FavoriteDevice>? favoriteDevices,
    bool? shouldCenter,
  }) {
    return MapLoadedState(
      currentPosition: currentPosition ?? this.currentPosition,
      favoriteDevices: favoriteDevices ?? this.favoriteDevices,
      shouldCenter: shouldCenter ?? this.shouldCenter,
    );
  }
}

class MapErrorState extends MapState {
  final String message;
  
  const MapErrorState(this.message);
  
  @override
  List<Object?> get props => [message];
} 