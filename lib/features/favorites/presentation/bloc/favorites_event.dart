import 'package:equatable/equatable.dart';
import '../../../../core/models/device.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavoritesEvent extends FavoritesEvent {
  const LoadFavoritesEvent();
}

class AddToFavoritesEvent extends FavoritesEvent {
  final Device device;

  const AddToFavoritesEvent(this.device);

  @override
  List<Object?> get props => [device];
}

class RemoveFromFavoritesEvent extends FavoritesEvent {
  final String deviceId;

  const RemoveFromFavoritesEvent(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class CheckIsFavoriteEvent extends FavoritesEvent {
  final String deviceId;

  const CheckIsFavoriteEvent(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
} 