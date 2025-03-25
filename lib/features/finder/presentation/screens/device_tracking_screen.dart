import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pod_finder_pro_178/features/finder/presentation/widgets/favorite_notification.dart';
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
  late AnimationController _pulseController;
  late AnimationController _distanceAnimationController;
  late Animation<double> _distanceAnimation;
  String? _notificationMessage;

  double _currentDistance = 10.0;

  @override
  void initState() {
    super.initState();

    if (widget.device.distance != null) {
      _currentDistance = widget.device.distance!;
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _distanceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
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
        final favoritesBloc =
            BlocProvider.of<FavoritesBloc>(context, listen: false);
        favoritesBloc.add(CheckIsFavoriteEvent(widget.device.id));
      }
    });
  }

  void _animateToNewDistance(double newDistance) {
    // Only animate if the change is significant
    if ((_currentDistance - newDistance).abs() > 0.02) {
      _distanceAnimationController.duration = const Duration(milliseconds: 150);
      _distanceAnimation = Tween<double>(
        begin: _currentDistance,
        end: newDistance,
      ).animate(CurvedAnimation(
        parent: _distanceAnimationController,
        curve: Curves.easeOutCubic,
      ));

      _distanceAnimationController.forward(from: 0.0);

      setState(() {
        _currentDistance = newDistance;
      });
    } else {
      setState(() {
        _currentDistance = newDistance;
      });
    }
  }

  Future<bool> _checkForDuplicateName(BuildContext context) async {
    final favoritesBloc = context.read<FavoritesBloc>();
    final state = favoritesBloc.state;
    if (state is FavoritesLoaded) {
      return state.favorites.any((fav) => 
        fav.name.toLowerCase() == widget.device.name.toLowerCase() && 
        fav.id != widget.device.id
      );
    }
    return false;
  }

  void _toggleFavorite(BuildContext context, bool isFavorite) async {
    HapticFeedback.mediumImpact();
    final favoritesBloc = context.read<FavoritesBloc>();
    
    if (isFavorite) {
      // Remove from favorites
      favoritesBloc.add(RemoveFromFavoritesEvent(widget.device.id));
      setState(() {
        _notificationMessage = 'Removed from Favorite';
      });
    } else {
      // Check for duplicate name before adding
      final hasDuplicate = await _checkForDuplicateName(context);
      if (hasDuplicate) {
        if (mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Duplicate Name'),
              content: const Text('A device with this name already exists in favorites.'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
        return;
      }
      
      // Add to favorites
      favoritesBloc.add(AddToFavoritesEvent(widget.device));
      setState(() {
        _notificationMessage = 'Added to Favorite';
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
          create: (context) =>
              DeviceTrackingBloc()..add(StartTrackingEvent(widget.device)),
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
                        style: TextStyle(
                          color: _getStateColor(trackingState),
                          fontSize: 34,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    if (_notificationMessage != null)
                      Center(
                        child: FavoriteNotification(
                          message: _notificationMessage!,
                          onDismissed: () {
                            if (mounted) {
                              setState(() {
                                _notificationMessage = null;
                              });
                            }
                          },
                        ),
                      ),
                    const SizedBox(height: 30),

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

                    const SizedBox(height: 0),

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
                                  width: trackingState == TrackingState.close
                                      ? 130
                                      : trackingState == TrackingState.nearby
                                          ? 64
                                          : 32,
                                  height: trackingState == TrackingState.close
                                      ? 130
                                      : trackingState == TrackingState.nearby
                                          ? 64
                                          : 32,
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
                                return current is DeviceIsFavorite ||
                                    current is FavoritesInitial;
                              },
                              builder: (context, favState) {
                                bool isFavorite = false;

                                if (favState is DeviceIsFavorite &&
                                    favState.deviceId == widget.device.id) {
                                  isFavorite = favState.isFavorite;
                                } else if (favState is FavoritesInitial) {
                                  context.read<FavoritesBloc>().add(
                                      CheckIsFavoriteEvent(widget.device.id));
                                }

                                return CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  child: SvgPicture.asset(
                                    isFavorite
                                        ? Assets.vector.favoritesActive
                                        : Assets.vector.favoritesInactive,
                                    fit: BoxFit.contain,
                                  ),
                                  onPressed: () => _toggleFavorite(context, isFavorite),
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
}
