import 'dart:ui';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import '../../../../core/models/favorite_device.dart';
import '../../../../core/navigation/app_navigator.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import 'package:pod_finder_pro_178/gen/assets.gen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapBloc _mapBloc;
  AppleMapController? _mapController;
  Set<Annotation> _annotations = {};
  DateTime _lastUpdate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _mapBloc = MapBloc();
    _mapBloc.add(const LoadMapEvent());
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final favoritesBloc = BlocProvider.of<FavoritesBloc>(context, listen: false);
        _mapBloc.subscribeFavoritesBloc(favoritesBloc);
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
  
  Future<void> _updateAnnotations(List<FavoriteDevice> devices, Position userPosition) async {
    Set<Annotation> annotations = {};
    
    annotations.add(
      Annotation(
        annotationId: AnnotationId('user_location'),
        position: LatLng(userPosition.latitude, userPosition.longitude),
        icon: BitmapDescriptor.defaultAnnotation,
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );
    
    for (final device in devices) {
      annotations.add(
        Annotation(
          annotationId: AnnotationId(device.id),
          position: LatLng(device.latitude, device.longitude),
          icon: BitmapDescriptor.defaultAnnotation,
          anchor: const Offset(0.5, 1.0),
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

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
  }

  Widget _buildDeviceInfoWindow(FavoriteDevice device) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Bluetooth icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: SvgPicture.asset(
                Assets.vector.blueLogo,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  CupertinoColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Device info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to track',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
          
          // Chevron
          const Icon(
            CupertinoIcons.chevron_right,
            color: CupertinoColors.systemGrey,
          ),
        ],
      ),
    );
  }
  
  void _navigateToDeviceTracking(FavoriteDevice device) {
    AppNavigator.navigateToTrackDevice(context, device.toDevice());
  }
  
  void _centerMap(Position position) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude)
      ),
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
            if (state is MapLoadedState && state.shouldCenter && _mapController != null) {
              _centerMap(state.currentPosition);
            }
            
            if (state is MapLoadedState) {
              _handleDevicesChange(state.favoriteDevices, state.currentPosition);
            }
          },
          builder: (context, state) {
            if (state is MapLoadingState) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            } else if (state is MapLoadedState) {
              return _buildMapContent(context, state);
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
  
  const CenterLocationButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(30),
      color: CupertinoColors.white,
      onPressed: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            Assets.vector.crosshair,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}

class _MapErrorView extends StatelessWidget {
  final String errorMessage;
  
  const _MapErrorView({required this.errorMessage});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 48,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Painter для треугольного указателя под маркером устройства
class TrianglePointer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = CupertinoColors.white
      ..style = PaintingStyle.fill;
    
    final Path path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    
    canvas.drawPath(path, paint);
    
    // Добавляем тень
    final Paint shadowPaint = Paint()
      ..color = CupertinoColors.systemGrey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawPath(path, shadowPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 