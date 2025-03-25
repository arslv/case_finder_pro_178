import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../../map/presentation/bloc/map_bloc.dart';
import '../../../map/presentation/bloc/map_event.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository _repository;
  
  FavoritesLoaded? _lastLoadedState;

  static FavoritesBloc? _instance;

  static FavoritesBloc get instance {
    _instance ??= FavoritesBloc._internal();
    return _instance!;
  }

  FavoritesBloc._internal()
      : _repository = FavoritesRepository.instance,
        super(const FavoritesInitial()) {
    on<LoadFavoritesEvent>(_onLoadFavorites);
    on<AddToFavoritesEvent>(_onAddToFavorites);
    on<RemoveFromFavoritesEvent>(_onRemoveFromFavorites);
    on<CheckIsFavoriteEvent>(_onCheckIsFavorite);
    
    _repository.init();
  }

  factory FavoritesBloc() {
    return instance;
  }

  void updateMap() {
    try {
      for (final mapBloc in MapBloc.instances) {
        mapBloc.add(const RefreshFavoritesEvent());
      }
    } catch (e) {
      debugPrint('Error updating map: $e');
    }
  }

  Future<void> _onLoadFavorites(
    LoadFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    if (_lastLoadedState == null) {
      emit(const FavoritesLoading());
    }
    
    try {
      final favorites = await _repository.getAllFavorites();
      _lastLoadedState = FavoritesLoaded(favorites);
      emit(_lastLoadedState!);
      
      updateMap();
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
        emit(DeviceIsFavorite(event.device.id, true));
        
        final favorites = await _repository.getAllFavorites();
        _lastLoadedState = FavoritesLoaded(favorites);
        
        emit(_lastLoadedState!);
        
        updateMap();
      } else {
        emit(const FavoritesError('Failed to add device to favorites'));
        
        if (_lastLoadedState != null) {
          emit(_lastLoadedState!);
        }
      }
    } catch (e) {
      emit(FavoritesError(e.toString()));
      
      if (_lastLoadedState != null) {
        emit(_lastLoadedState!);
      }
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavoritesEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final success = await _repository.removeFromFavorites(event.deviceId);
      
      if (success) {
        emit(DeviceIsFavorite(event.deviceId, false));
        
        final favorites = await _repository.getAllFavorites();
        _lastLoadedState = FavoritesLoaded(favorites);
        
        emit(_lastLoadedState!);
        
        updateMap();
      } else {
        emit(const FavoritesError('Failed to remove device from favorites'));
        
        if (_lastLoadedState != null) {
          emit(_lastLoadedState!);
        }
      }
    } catch (e) {
      emit(FavoritesError(e.toString()));
      
      if (_lastLoadedState != null) {
        emit(_lastLoadedState!);
      }
    }
  }
  
  Future<void> _onCheckIsFavorite(
    CheckIsFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isFavorite = await _repository.isFavorite(event.deviceId);
      
      emit(DeviceIsFavorite(event.deviceId, isFavorite));
      
      if (_lastLoadedState != null) {
        await Future.delayed(const Duration(milliseconds: 50));
        emit(_lastLoadedState!);
      }
    } catch (e) {
      emit(DeviceIsFavorite(event.deviceId, false));
      
      if (_lastLoadedState != null) {
        await Future.delayed(const Duration(milliseconds: 50));
        emit(_lastLoadedState!);
      }
    }
  }
} 