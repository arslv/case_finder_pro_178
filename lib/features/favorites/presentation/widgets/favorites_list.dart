import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/favorite_device.dart';
import '../../../finder/presentation/widgets/device_list.dart';
import '../../../finder/presentation/bloc/finder_bloc.dart';

class FavoritesList extends StatelessWidget {
  final List<FavoriteDevice> favorites;

  const FavoritesList({
    super.key,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    final devices = favorites.map((fav) => fav.toDevice()).toList();
    
    return BlocProvider(
      create: (context) => FinderBloc(),
      child: DeviceList(
        devices: devices,
        title: 'Saved',
        showHelpButton: false,
      ),
    );
  }
} 