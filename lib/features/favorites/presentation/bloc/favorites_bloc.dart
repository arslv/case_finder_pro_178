import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/favorites_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesBloc()
      : _repository = FavoritesRepository.instance,
        super(const FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<AddToFavoritesEvent>(_onAddToFavorites);
    on<RemoveFromFavoritesEvent>(_onRemoveFromFavorites);
    on<CheckIsFavoriteEvent>(_onCheckIsFavorite);
    
    _repository.init();
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(const FavoritesLoading());
    
    try {
      final favorites = await _repository.getAllFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onAddToFavorites(
    AddToFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final success = await _repository.addToFavorites(event.device);
      
      if (success) {
        // First update the favorite status
        emit(DeviceIsFavorite(event.device.id, true));
        
        // Then reload the favorites list 
        final favorites = await _repository.getAllFavorites();
        emit(FavoritesLoaded(favorites));
      } else {
        emit(const FavoritesError('Failed to add device to favorites'));
        
        // Reload current state
        final favorites = await _repository.getAllFavorites();
        emit(FavoritesLoaded(favorites));
      }
    } catch (e) {
      emit(FavoritesError(e.toString()));
      
      // Reload current state
      final favorites = await _repository.getAllFavorites();
      emit(FavoritesLoaded(favorites));
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final success = await _repository.removeFromFavorites(event.deviceId);
      
      if (success) {
        // First update the favorite status
        emit(DeviceIsFavorite(event.deviceId, false));
        
        // Then reload the favorites list
        final favorites = await _repository.getAllFavorites();
        emit(FavoritesLoaded(favorites));
      } else {
        emit(const FavoritesError('Failed to remove device from favorites'));
        
        // Reload current state
        final favorites = await _repository.getAllFavorites();
        emit(FavoritesLoaded(favorites));
      }
    } catch (e) {
      emit(FavoritesError(e.toString()));
      
      // Reload current state
      final favorites = await _repository.getAllFavorites();
      emit(FavoritesLoaded(favorites));
    }
  }
  
  Future<void> _onCheckIsFavorite(
    CheckIsFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isFavorite = await _repository.isFavorite(event.deviceId);
      emit(DeviceIsFavorite(event.deviceId, isFavorite));
    } catch (e) {
      emit(DeviceIsFavorite(event.deviceId, false));
    }
  }
} 