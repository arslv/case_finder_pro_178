import 'package:equatable/equatable.dart';
import '../../../../core/models/favorite_device.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteDevice> favorites;

  const FavoritesLoaded(this.favorites);

  @override
  List<Object?> get props => [favorites];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError(this.message);

  @override
  List<Object?> get props => [message];
}

class DeviceIsFavorite extends FavoritesState {
  final bool isFavorite;
  final String deviceId;

  const DeviceIsFavorite(this.deviceId, this.isFavorite);

  @override
  List<Object?> get props => [deviceId, isFavorite];
} 