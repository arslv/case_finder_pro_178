import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/device.dart';
import '../../../../core/models/favorite_device.dart';
import '../../../finder/presentation/widgets/device_list.dart';
import '../../../finder/presentation/bloc/finder_bloc.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';

class FavoritesList extends StatelessWidget {
  final List<FavoriteDevice> favorites;

  const FavoritesList({
    super.key,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    // Convert FavoriteDevice list to Device list
    final devices = favorites.map((fav) => fav.toDevice()).toList();
    
    // Wrap DeviceList with FinderBloc provider
    return BlocProvider(
      create: (context) => FinderBloc(),
      child: DeviceList(
        devices: devices,
        showHelpButton: false,
      ),
    );
  }
} 