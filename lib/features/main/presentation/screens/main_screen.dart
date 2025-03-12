import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pod_finder_pro_178/features/finder/presentation/finder_screen.dart';
import '../../../../core/navigation/nav_bar_item.dart';
import '../../../../core/widgets/custom_nav_bar.dart';
import '../../../finder/presentation/screens/finder_screen.dart';
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
      // screen: const CaseFinderScreen(),
      screen: const Placeholder(),
    ),
    NavBarItem(
      label: 'Map',
      activeIcon: 'assets/vector/map_active.svg',
      inactiveIcon: 'assets/vector/map_inactive.svg',
      // screen: const MapScreen(),
      screen: const Placeholder(),
    ),
    NavBarItem(
      label: 'Favorites',
      activeIcon: 'assets/vector/favorites_active.svg',
      inactiveIcon: 'assets/vector/favorites_inactive.svg',
      // screen: const FavoritesScreen(),
      screen: const Placeholder(),
    ),
    NavBarItem(
      label: 'Settings',
      activeIcon: 'assets/vector/settings_active.svg',
      inactiveIcon: 'assets/vector/settings_inactive.svg',
      // screen: const SettingsScreen(),
      screen: const Placeholder(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainScreenBloc, MainScreenState>(
      builder: (context, state) {
        return CupertinoPageScaffold(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 49),
                child: IndexedStack(
                  index: state.currentIndex,
                  children: _navBarItems.map((item) => item.screen).toList(),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomNavBar(
                  items: _navBarItems,
                  currentIndex: state.currentIndex,
                  onTap: (index) {
                    context.read<MainScreenBloc>().add(TabChanged(index));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 