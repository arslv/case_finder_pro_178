import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pod_finder_pro_178/core/widgets/app_button.dart';
import 'package:pod_finder_pro_178/core/widgets/pro_button.dart';
import 'package:pod_finder_pro_178/features/main/presentation/bloc/main_screen_bloc.dart';
import 'package:pod_finder_pro_178/gen/assets.gen.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';
import '../widgets/favorites_list.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    context.read<FavoritesBloc>().add(const LoadFavoritesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.featuresBg,
      navigationBar: const CustomAppBar(
        title: 'Favorites',
        suffix: ProButton(),
      ),
      child: SafeArea(
        child: BlocConsumer<FavoritesBloc, FavoritesState>(
          listenWhen: (previous, current) {
            return previous is DeviceIsFavorite && current is! DeviceIsFavorite;
          },
          listener: (context, state) {
            if (state is FavoritesInitial) {
              _loadFavorites();
            }
          },
          buildWhen: (previous, current) {
            return current is FavoritesLoading ||
                current is FavoritesLoaded ||
                current is FavoritesError ||
                current is FavoritesInitial;
          },
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const Center(
                child: CupertinoActivityIndicator(
                  color: AppColors.secondary,
                ),
              );
            }

            if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      SvgPicture.asset(
                        Assets.vector.caseFinderInactive,
                        width: 100,
                        height: 100,
                        color: AppColors.primary.withOpacity(0.14),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Nothing here yet',
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Your saved devices will appear here.',
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 64),
                        child: AppButton(
                          text: 'Scan',
                          onPressed: () {
                            context.read<MainScreenBloc>().add(TabChanged(0));
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }

              return FavoritesList(favorites: state.favorites);
            }

            if (state is FavoritesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.exclamationmark_circle,
                      size: 48,
                      color: CupertinoColors.destructiveRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load favorites',
                      style: TextStyle(
                        color: CupertinoColors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _loadFavorites,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: CupertinoActivityIndicator(
                color: AppColors.secondary,
              ),
            );
          },
        ),
      ),
    );
  }
}
