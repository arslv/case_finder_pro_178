import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:pod_finder_pro_178/core/theme/app_colors.dart';
import 'package:pod_finder_pro_178/core/widgets/app_button.dart';
import '../../../../core/models/favorite_device.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../widgets/device_map_marker.dart';
import '../widgets/user_location_marker.dart';
import '../utils/widget_to_apple_marker.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import 'package:pod_finder_pro_178/gen/assets.gen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapBloc _mapBloc;
  late AppleMapController _mapController;
  Set<Annotation> _annotations = {};
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _mapBloc = MapBloc();
    _mapBloc.add(const LoadMapEvent());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final favoritesBloc =
            BlocProvider.of<FavoritesBloc>(context, listen: false);
        _mapBloc.subscribeFavoritesBloc(favoritesBloc);

        _mapBloc.add(const RefreshFavoritesEvent());
      }
    });
  }

  void _handleDevicesChange(List<FavoriteDevice> devices, Position position) {
    final now = DateTime.now();
    if (now.difference(_lastUpdate).inMilliseconds < 300) {
      return;
    }
    _lastUpdate = now;

    _updateAnnotations(devices, position);
  }

  Future<void> _updateAnnotations(
      List<FavoriteDevice> devices, Position userPosition) async {
    final Set<Annotation> annotations = {};

    final userLocationBitmap = await widgetToAppleMarker(
      const UserLocationMarker(size: 32),
      width: 32,
      height: 32,
    );

    annotations.add(
      Annotation(
        annotationId: AnnotationId('user_location'),
        position: LatLng(userPosition.latitude, userPosition.longitude),
        icon: userLocationBitmap,
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );

    for (final device in devices) {
      final deviceMarker = DeviceMapMarker(device: device);
      final markerBitmap = await widgetToAppleMarker(
        deviceMarker,
        width: 220,
        height: 67, // Includes the pointer
      );

      annotations.add(
        Annotation(
          annotationId: AnnotationId(device.id),
          position: LatLng(device.latitude, device.longitude),
          icon: markerBitmap,
          anchor: const Offset(0.5, 1.0),
          // Bottom center of the marker
          onTap: () => _navigateToDeviceTracking(device),
          infoWindow: InfoWindow(
            title: device.name,
            snippet: 'Tap to track',
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _annotations = annotations;
      });
    }
  }

  void _navigateToDeviceTracking(FavoriteDevice device) {
    AppNavigator.navigateToTrackDevice(context, device.toDevice());
  }

  void _centerMap(Position position) {
    _mapController.animateCamera(
      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
    );
  }

  @override
  void dispose() {
    _mapBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: BlocProvider(
        create: (context) => _mapBloc,
        child: BlocConsumer<MapBloc, MapState>(
          listener: (context, state) {
            if (state is MapLoadedState &&
                state.shouldCenter &&
                _mapController != null) {
              _centerMap(state.currentPosition);
            }

            if (state is MapLoadedState) {
              _handleDevicesChange(
                  state.favoriteDevices, state.currentPosition);
            }
          },
          builder: (context, state) {
            if (state is MapLoadingState) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            } else if (state is MapLoadedState) {
              if (state.hasPermission) {
                return _buildMapContent(context, state);
              } else {
                return _MapErrorView();
              }
            } else if (state is MapErrorState) {
              return _MapErrorView(errorMessage: state.message);
            }

            return const Center(
              child: CupertinoActivityIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapContent(BuildContext context, MapLoadedState state) {
    return Stack(
      children: [
        AppleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              state.currentPosition.latitude,
              state.currentPosition.longitude,
            ),
            zoom: 14.0,
          ),
          onMapCreated: (AppleMapController controller) {
            setState(() {
              _mapController = controller;
            });
          },
          mapType: MapType.standard,
          annotations: _annotations,
        ),
        Positioned(
          right: 16,
          bottom: 30,
          child: CenterLocationButton(
            onPressed: () => _mapBloc.add(const CenterMapEvent()),
          ),
        ),
      ],
    );
  }
}

class CenterLocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CenterLocationButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(16),
      color: CupertinoColors.white,
      onPressed: onPressed,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Center(
          child: SvgPicture.asset(
            Assets.vector.crosshair,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _MapErrorView extends StatelessWidget {
  final String? errorMessage;

  const _MapErrorView({this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: errorMessage != null
              ? [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: 48,
                    color: CupertinoColors.systemRed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ]
              : [
                  SvgPicture.asset(
                    Assets.vector.mapInactive,
                    width: 100,
                    height: 100,
                    color: AppColors.primary.withOpacity(0.14),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Location Services Disabled',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    'Go to Settings > Privacy & Security >\nLocation Services and turn on location\naccess',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: AppButton(
                      text: 'Enable Location',
                      onPressed: () async {
                          final mapBloc = context.read<MapBloc>();
                          mapBloc.add(const LoadMapEvent());
                      },
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}
