import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _FavoritesScreenState extends State<FavoritesScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
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
    super.build(context);
    
    return CupertinoPageScaffold(
      backgroundColor: AppColors.featuresBg,
      navigationBar: const CustomAppBar(
        title: 'Favorites',
      ),
      child: SafeArea(
        child: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const _LoadingView();
            }
            
            if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return const _EmptyFavoritesView();
              }
              return FavoritesList(favorites: state.favorites);
            }

            if (state is FavoritesError) {
              return _ErrorView(
                onRetry: _loadFavorites,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CupertinoActivityIndicator(
        color: AppColors.secondary,
      ),
    );
  }
}

class _EmptyFavoritesView extends StatelessWidget {
  const _EmptyFavoritesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.heart,
            size: 48,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved devices yet',
            style: TextStyle(
              color: CupertinoColors.black.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
              color: CupertinoColors.black.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          CupertinoButton(
            child: const Text('Try Again'),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
