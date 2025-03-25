import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pod_finder_pro_178/features/case_finder/presentation/screens/case_finder_screen.dart';
import 'package:pod_finder_pro_178/features/finder/presentation/screens/finder_screen.dart';
import 'package:pod_finder_pro_178/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:pod_finder_pro_178/features/map/presentation/screens/map_screen.dart';
import 'package:pod_finder_pro_178/features/settings/presentation/screens/settings_screen.dart';
import '../../../../core/navigation/nav_bar_item.dart';
import '../../../../core/widgets/custom_nav_bar.dart';
import '../bloc/main_screen_bloc.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final List<NavBarItem> _navBarItems = [
    NavBarItem(
      label: 'Finder',
      activeIcon: 'assets/vector/finder_active.svg',
      inactiveIcon: 'assets/vector/finder_inactive.svg',
      screen: FinderScreen(),
    ),
    NavBarItem(
      label: 'Case Finder',
      activeIcon: 'assets/vector/case_finder_active.svg',
      inactiveIcon: 'assets/vector/case_finder_inactive.svg',
      screen: const CaseFinderScreen(),
    ),
    NavBarItem(
      label: 'Map',
      activeIcon: 'assets/vector/map_active.svg',
      inactiveIcon: 'assets/vector/map_inactive.svg',
      screen: const MapScreen(),
    ),
    NavBarItem(
      label: 'Favorites',
      activeIcon: 'assets/vector/favorites_active_page.svg',
      inactiveIcon: 'assets/vector/favorites_inactive_page.svg',
      screen: const FavoritesScreen(),
    ),
    NavBarItem(
      label: 'Settings',
      activeIcon: 'assets/vector/settings_active.svg',
      inactiveIcon: 'assets/vector/settings_inactive.svg',
      // screen: const SettingsScreen(),
      screen: const SettingsScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainScreenBloc, MainScreenState>(
      builder: (context, state) {
        return CupertinoPageScaffold(
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: state.currentIndex,
                  children: _navBarItems.map((item) => item.screen).toList(),
                ),
              ),
              CustomNavBar(
                items: _navBarItems,
                currentIndex: state.currentIndex,
                onTap: (index) {
                  context.read<MainScreenBloc>().add(TabChanged(index));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
