import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/models/favorite_device.dart';
import '../../../../core/services/geolocation/geolocation_service.dart';
import '../../../favorites/domain/repositories/favorites_repository.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import 'map_event.dart';
import 'map_state.dart';
import 'package:flutter/foundation.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final FavoritesRepository _favoritesRepository = FavoritesRepository.instance;
  final GeolocationService _geolocationService = GeolocationService();
  
  StreamSubscription? _positionStreamSubscription;
  StreamSubscription? _favoritesSubscription;
  FavoritesBloc? _favoritesBloc;

  Position? _lastKnownPosition;
  List<FavoriteDevice> _lastKnownDevices = [];
  
  MapBloc() : super(const MapInitialState()) {
    on<LoadMapEvent>(_onLoadMap);
    on<CenterMapEvent>(_onCenterMap);
    on<DeviceSelectedEvent>(_onDeviceSelected);
    on<UpdatePositionEvent>(_onUpdatePosition);
    on<RefreshFavoritesEvent>(_onRefreshFavorites);
  }
  
  void subscribeFavoritesBloc(FavoritesBloc favoritesBloc) {
    // Cancel previous subscription to prevent memory leaks
    _favoritesSubscription?.cancel();
    
    _favoritesBloc = favoritesBloc;
    
    _favoritesSubscription = _favoritesBloc!.stream.listen((favoritesState) {
      if (favoritesState is FavoritesLoaded) {
        add(RefreshFavoritesEvent());
      }
    });
  }
  
  void _startPositionTracking() {
    // Cancel previous subscription to prevent memory leaks
    _positionStreamSubscription?.cancel();
    
    // Update position every 15 seconds with low accuracy to save battery
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        distanceFilter: 10,
        timeLimit: Duration(seconds: 15),
      ),
    ).listen(
      (Position position) {
        add(UpdatePositionEvent(position));
        _lastKnownPosition = position;
      },
      onError: (e) {
        debugPrint('Position stream error: $e');
      }
    );
  }
  
  Future<void> _onLoadMap(
    LoadMapEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoadingState());
    
    try {
      // Use cached data if available to improve responsiveness
      if (_lastKnownPosition != null && _lastKnownDevices.isNotEmpty) {
        emit(MapLoadedState(
          currentPosition: _lastKnownPosition!,
          favoriteDevices: _lastKnownDevices,
        ));
        
        unawaited(_updateMapDataInBackground(emit));
        return;
      }
      
      // Get location permission
      final hasPermission = await _geolocationService.requestPermission();
      
      // Get current position safely (always returns a position)
      final currentPosition = await _geolocationService.getPositionSafely();
      _lastKnownPosition = currentPosition;
      
      // Get favorite devices
      final favoriteDevices = await _favoritesRepository.getAllFavorites();
      _lastKnownDevices = favoriteDevices;
      
      emit(MapLoadedState(
        currentPosition: currentPosition,
        favoriteDevices: favoriteDevices,
      ));
      
      if (hasPermission) {
        _startPositionTracking();
      }
    } catch (e) {
      emit(MapErrorState('Error loading map: ${e.toString()}'));
    }
  }
  
  Future<void> _updateMapDataInBackground(Emitter<MapState> emit) async {
    try {
      final hasPermission = await _geolocationService.requestPermission();
      
      // Get updated favorites list
      final favoriteDevices = await _favoritesRepository.getAllFavorites();
      _lastKnownDevices = favoriteDevices;
      
      if (hasPermission) {
        // Get updated position if permission granted
        final currentPosition = await _geolocationService.getPositionSafely();
        _lastKnownPosition = currentPosition;
        
        if (state is MapLoadedState) {
          emit(MapLoadedState(
            currentPosition: currentPosition,
            favoriteDevices: favoriteDevices,
          ));
        }
        
        _startPositionTracking();
      } else if (state is MapLoadedState) {
        // Update only favorites list if permission not granted
        final currentState = state as MapLoadedState;
        emit(currentState.copyWith(
          favoriteDevices: favoriteDevices,
        ));
      }
    } catch (e) {
      debugPrint('Background map data update failed: $e');
    }
  }
  
  Future<void> _onCenterMap(
    CenterMapEvent event,
    Emitter<MapState> emit,
  ) async {
    if (state is MapLoadedState) {
      final currentState = state as MapLoadedState;
      
      try {
        final currentPosition = await _geolocationService.getPositionSafely();
        _lastKnownPosition = currentPosition;
        
        emit(currentState.copyWith(
          currentPosition: currentPosition,
          shouldCenter: true,
        ));
        
        // Reset the centering flag after a short delay
        emit(currentState.copyWith(
          currentPosition: currentPosition,
          shouldCenter: false,
        ));
      } catch (e) {
        debugPrint('Error centering map: $e');
      }
    }
  }
  
  void _onDeviceSelected(
    DeviceSelectedEvent event,
    Emitter<MapState> emit,
  ) {
    // Implementation not needed yet
  }
  
  void _onUpdatePosition(
    UpdatePositionEvent event,
    Emitter<MapState> emit,
  ) {
    if (state is MapLoadedState) {
      final currentState = state as MapLoadedState;
      _lastKnownPosition = event.position;
      
      emit(currentState.copyWith(
        currentPosition: event.position,
      ));
    }
  }
  
  Future<void> _onRefreshFavorites(
    RefreshFavoritesEvent event,
    Emitter<MapState> emit,
  ) async {
    if (state is MapLoadedState) {
      final currentState = state as MapLoadedState;
      
      try {
        final favorites = await _favoritesRepository.getAllFavorites();
        _lastKnownDevices = favorites;
        
        emit(currentState.copyWith(
          favoriteDevices: favorites,
        ));
      } catch (e) {
        debugPrint('Error refreshing favorites: $e');
      }
    }
  }
  
  @override
  Future<void> close() {
    _positionStreamSubscription?.cancel();
    _favoritesSubscription?.cancel();
    return super.close();
  }
} 