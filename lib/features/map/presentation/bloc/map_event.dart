import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/models/favorite_device.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadMapEvent extends MapEvent {
  const LoadMapEvent();
}

class CenterMapEvent extends MapEvent {
  const CenterMapEvent();
}

class DeviceSelectedEvent extends MapEvent {
  final FavoriteDevice device;
  
  const DeviceSelectedEvent(this.device);
  
  @override
  List<Object?> get props => [device];
}

class UpdatePositionEvent extends MapEvent {
  final Position position;
  
  const UpdatePositionEvent(this.position);
  
  @override
  List<Object?> get props => [position];
}

class RefreshFavoritesEvent extends MapEvent {
  const RefreshFavoritesEvent();
} 