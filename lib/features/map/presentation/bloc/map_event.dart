import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/models/favorite_device.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();
  
  @override
  List<Object?> get props => [];
}

// Event to load the map with favorite devices
class LoadMapEvent extends MapEvent {
  const LoadMapEvent();
}

// Event to center the map on user's current location
class CenterMapEvent extends MapEvent {
  const CenterMapEvent();
}

// Event when a device on the map is selected
class DeviceSelectedEvent extends MapEvent {
  final FavoriteDevice device;
  
  const DeviceSelectedEvent(this.device);
  
  @override
  List<Object?> get props => [device];
}

// Event to update the user's position on the map
class UpdatePositionEvent extends MapEvent {
  final Position position;
  
  const UpdatePositionEvent(this.position);
  
  @override
  List<Object?> get props => [position];
}

class RefreshFavoritesEvent extends MapEvent {
  const RefreshFavoritesEvent();
} 