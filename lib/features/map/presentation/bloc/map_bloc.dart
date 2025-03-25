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

  static final List<MapBloc> instances = [];

  MapBloc() : super(const MapInitialState()) {
    on<LoadMapEvent>(_onLoadMap);
    on<CenterMapEvent>(_onCenterMap);
    on<DeviceSelectedEvent>(_onDeviceSelected);
    on<UpdatePositionEvent>(_onUpdatePosition);
    on<RefreshFavoritesEvent>(_onRefreshFavorites);

    instances.add(this);
  }

  void subscribeFavoritesBloc(FavoritesBloc favoritesBloc) {
    _favoritesSubscription?.cancel();

    _favoritesBloc = favoritesBloc;

    _favoritesSubscription = _favoritesBloc!.stream.listen((favoritesState) {
      if (favoritesState is FavoritesLoaded) {
        add(RefreshFavoritesEvent());
      }
    });
  }

  void _startPositionTracking() {
    _positionStreamSubscription?.cancel();

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        distanceFilter: 10,
        timeLimit: Duration(seconds: 15),
      ),
    ).listen((Position position) {
      add(UpdatePositionEvent(position));
      _lastKnownPosition = position;
    }, onError: (e) {
      debugPrint('Position stream error: $e');
    });
  }

  Future<void> _onLoadMap(
    LoadMapEvent event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoadingState());

    try {
      if (_lastKnownPosition != null && _lastKnownDevices.isNotEmpty) {
        emit(MapLoadedState(
          currentPosition: _lastKnownPosition!,
          favoriteDevices: _lastKnownDevices,
        ));

        unawaited(_updateMapDataInBackground(emit));
        return;
      }

      final hasPermission = await _geolocationService.requestPermission();

      final currentPosition = await _geolocationService.getPositionSafely();
      _lastKnownPosition = currentPosition;

      final favoriteDevices = await _favoritesRepository.getAllFavorites();
      _lastKnownDevices = favoriteDevices;

      emit(MapLoadedState(
        currentPosition: currentPosition,
        favoriteDevices: favoriteDevices,
        hasPermission: hasPermission,
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

      final favoriteDevices = await _favoritesRepository.getAllFavorites();
      _lastKnownDevices = favoriteDevices;

      if (hasPermission) {
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

    instances.remove(this);

    return super.close();
  }
}
