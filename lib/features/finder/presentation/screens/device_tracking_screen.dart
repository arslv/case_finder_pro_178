import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../../core/models/device.dart';
import '../../../../core/services/device_tracking/device_tracking_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../gen/assets.gen.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import '../bloc/device_tracking_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../favorites/presentation/bloc/favorites_event.dart';

class DeviceTrackingScreen extends StatefulWidget {
  final Device device;

  const DeviceTrackingScreen({
    super.key,
    required this.device,
  });

  @override
  State<DeviceTrackingScreen> createState() => _DeviceTrackingScreenState();
}

class _DeviceTrackingScreenState extends State<DeviceTrackingScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _distanceAnimationController;

  // Animation for distance changes
  late Animation<double> _distanceAnimation;

  // Current distance value for animation
  double _currentDistance = 10.0;

  @override
  void initState() {
    super.initState();

    // Initialize with the device's distance if available
    if (widget.device.distance != null) {
      _currentDistance = widget.device.distance!;
    }

    // Pulse animation for the concentric circles
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Animation controller for smooth distance transitions
    _distanceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _distanceAnimation = Tween<double>(
      begin: _currentDistance,
      end: _currentDistance,
    ).animate(CurvedAnimation(
      parent: _distanceAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Schedule the checking of favorites status after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final favoritesBloc = BlocProvider.of<FavoritesBloc>(context, listen: false);
        favoritesBloc.add(CheckIsFavoriteEvent(widget.device.id));
      }
    });
  }

  void _animateToNewDistance(double newDistance) {
    // Only animate if the change is significant
    if ((_currentDistance - newDistance).abs() > 0.05) {
      _distanceAnimationController.duration = const Duration(milliseconds: 300);
      _distanceAnimation = Tween<double>(
        begin: _currentDistance,
        end: newDistance,
      ).animate(CurvedAnimation(
        parent: _distanceAnimationController,
        curve: Curves.easeOutCubic,
      ));

      _distanceAnimationController.forward(from: 0.0);

      // Update current distance
      setState(() {
        _currentDistance = newDistance;
      });
    } else {
      // Even for small changes, update the current distance without animation
      setState(() {
        _currentDistance = newDistance;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _distanceAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DeviceTrackingBloc>(
          create: (context) => DeviceTrackingBloc()..add(StartTrackingEvent(widget.device)),
        ),
        BlocProvider.value(
          value: BlocProvider.of<FavoritesBloc>(context, listen: false),
        ),
      ],
      child: BlocListener<DeviceTrackingBloc, DeviceTrackingState>(
        listener: (context, state) {
          if (state is DeviceTrackingInProgress) {
            _animateToNewDistance(state.distance);
          } else if (state is DeviceTrackingError) {
            debugPrint('Tracking error: ${state.message}');
          }
        },
        child: BlocBuilder<DeviceTrackingBloc, DeviceTrackingState>(
          buildWhen: (previous, current) {
            // Rebuild on any state change in DeviceTrackingInProgress
            if (previous.runtimeType != current.runtimeType) {
              return true;
            }

            if (previous is DeviceTrackingInProgress &&
                current is DeviceTrackingInProgress) {
              // Always rebuild on distance changes
              final prevState = previous as DeviceTrackingInProgress;
              final currState = current as DeviceTrackingInProgress;

              final distanceChanged =
                  (prevState.distance - currState.distance).abs() > 0.01;
              final stateChanged =
                  prevState.trackingState != currState.trackingState;

              if (distanceChanged || stateChanged) {
                return true;
              }
            }

            return false;
          },
          builder: (context, state) {
            TrackingState trackingState = TrackingState.far;

            // Update tracking state if available
            if (state is DeviceTrackingInProgress) {
              trackingState = state.trackingState;
            }

            return CupertinoPageScaffold(
              backgroundColor: Colors.black,
              navigationBar: CupertinoNavigationBar(
                padding: EdgeInsetsDirectional.only(start: 16, top: 16),
                backgroundColor: Colors.black,
                leading: Text(
                  'FINDING',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: Text(
                        widget.device.name.isEmpty
                            ? "Cubitt CT2s"
                            : widget.device.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Center(
                      child: AnimatedBuilder(
                        animation: _distanceAnimation,
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(
                                      fontSize: 44,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                child: Text(
                                  _distanceAnimation.value.toStringAsFixed(1),
                                ),
                              ),
                              Text(
                                ' m',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge!
                                    .copyWith(
                                      color: AppColors.secondary,
                                      fontSize: 34,
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 30),

                    Expanded(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Concentric circles
                                ...List.generate(5, (index) {
                                  final delay = index * 0.2;
                                  final value =
                                      (_pulseController.value + delay) % 1.0;
                                  final opacity = (1.0 - value) * 0.9;

                                  // Adjust pulse speed based on distance
                                  final pulseSize = 350 * value;

                                  return Container(
                                    width: pulseSize,
                                    height: pulseSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _getStateColor(trackingState)
                                            .withOpacity(opacity),
                                        width: 1,
                                      ),
                                    ),
                                  );
                                }),

                                // Center indicator
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: trackingState == TrackingState.close ? 130 : trackingState == TrackingState.nearby ? 64 : 32,
                                  height: trackingState == TrackingState.close ? 130 : trackingState == TrackingState.nearby ? 64 : 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _getStateColor(trackingState),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: trackingState == TrackingState.close
                                        ? const Icon(
                                            CupertinoIcons.check_mark,
                                            key: ValueKey('check_icon'),
                                            color: Colors.white,
                                            size: 64,
                                          )
                                        : const SizedBox.shrink(
                                            key: ValueKey('empty_icon'),
                                          ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Status text
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 0, left: 16, right: 16, bottom: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w700,
                                  color: _getStateColor(trackingState),
                                ),
                            child: Text(_getStateText(trackingState)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getStateDescription(trackingState),
                            key: ValueKey(
                                'description_${trackingState.toString()}'),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    ),

                    // Close button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16, top: 16),
                      child: Row(
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF787880).withOpacity(0.32),
                                shape: BoxShape.circle,
                              ),
                              width: 50,
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SvgPicture.asset(
                                  Assets.vector.exit,
                                  fit: BoxFit.contain,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                            onPressed: () {
                              context
                                  .read<DeviceTrackingBloc>()
                                  .add(const StopTrackingEvent());
                              Navigator.of(context).pop();
                            },
                          ),
                          const Spacer(),
                          
                          // Only show favorites button when device is nearby or close
                          if (trackingState == TrackingState.nearby || 
                              trackingState == TrackingState.close)
                            BlocBuilder<FavoritesBloc, FavoritesState>(
                              buildWhen: (previous, current) {
                                // Обновлять только когда изменяется статус избранного
                                return current is DeviceIsFavorite || 
                                       current is FavoritesInitial;
                              },
                              builder: (context, favState) {
                                // Проверяем, находится ли устройство в избранном
                                bool isFavorite = false;
                                
                                if (favState is DeviceIsFavorite && 
                                    favState.deviceId == widget.device.id) {
                                  isFavorite = favState.isFavorite;
                                } else if (favState is FavoritesInitial) {
                                  // Запрашиваем проверку для этого устройства
                                  context.read<FavoritesBloc>().add(CheckIsFavoriteEvent(widget.device.id));
                                }
                                
                                return CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: SvgPicture.asset(
                                    isFavorite
                                        ? Assets.vector.favoritesActive
                                        : Assets.vector.favoritesInactive,
                                    fit: BoxFit.contain,
                                  ),
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    if (isFavorite) {
                                      _showRemoveFromFavoritesDialog(context);
                                    } else {
                                      _showAddToFavoritesBottomSheet(context);
                                    }
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStateColor(TrackingState trackingState) {
    switch (trackingState) {
      case TrackingState.close:
        return const Color(0xFF4CD964); // iOS green
      case TrackingState.nearby:
        return const Color(0xFFFFCC00); // iOS yellow
      case TrackingState.far:
        return Colors.white;
    }
  }

  String _getStateText(TrackingState trackingState) {
    switch (trackingState) {
      case TrackingState.close:
        return 'Close';
      case TrackingState.nearby:
        return 'Nearby';
      case TrackingState.far:
        return 'Far';
    }
  }

  String _getStateDescription(TrackingState trackingState) {
    switch (trackingState) {
      case TrackingState.far:
        return 'The device appears to be far away.\nTry moving around to locate it!';
      case TrackingState.nearby:
        return "The device is nearby. Keep going,\nyou're on the right track!";
      case TrackingState.close:
        return "The device is right next to you!\nYou've located it – great job!";
    }
  }

  void _showAddToFavoritesBottomSheet(BuildContext context) {
    final trackingBloc = context.read<DeviceTrackingBloc>();
    final favoritesBloc = context.read<FavoritesBloc>();
    
    bool isAlreadyFavorite = false;
    
    final favState = favoritesBloc.state;
    if (favState is DeviceIsFavorite && 
        favState.deviceId == widget.device.id) {
      isAlreadyFavorite = favState.isFavorite;
    } else {
      favoritesBloc.add(CheckIsFavoriteEvent(widget.device.id));
    }
    
    showCupertinoModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1C1C1E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isAlreadyFavorite ? 'Device Info' : 'Save Device',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isAlreadyFavorite 
                    ? 'This device is already saved to favorites.'
                    : 'This will save the device with your current location. You can later find it on the favorites screen or map.',
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.device_phone_portrait,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.device.name,
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (trackingBloc.state is DeviceTrackingInProgress)
                        Text(
                          'Distance: ${(trackingBloc.state as DeviceTrackingInProgress).distance.toStringAsFixed(1)} m',
                          style: TextStyle(
                            color: CupertinoColors.white.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              if (!isAlreadyFavorite)
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                    child: const Text(
                      'Save to Favorites',
                      style: TextStyle(
                        color: CupertinoColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      favoritesBloc.add(AddToFavoritesEvent(widget.device));
                      Navigator.pop(context);
                    },
                  ),
                ),
              if (isAlreadyFavorite)
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: CupertinoColors.destructiveRed,
                    borderRadius: BorderRadius.circular(12),
                    child: const Text(
                      'Remove from Favorites',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      favoritesBloc.add(RemoveFromFavoritesEvent(widget.device.id));
                      Navigator.pop(context);
                    },
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showRemoveFromFavoritesDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Remove from Favorites'),
          content: const Text('Are you sure you want to remove this device from favorites?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: const Text('Remove'),
              onPressed: () {
                HapticFeedback.mediumImpact();
                final favoritesBloc = context.read<FavoritesBloc>();
                favoritesBloc.add(RemoveFromFavoritesEvent(widget.device.id));
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
