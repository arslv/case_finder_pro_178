import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pod_finder_pro_178/core/widgets/app_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/finder_bloc.dart';
import '../bloc/finder_event.dart';
import '../bloc/finder_state.dart';
import '../widgets/device_list.dart';
import '../widgets/scanning_animation.dart';

class FinderScreen extends StatelessWidget {
  const FinderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FinderBloc(),
      child: const FinderScreenContent(),
    );
  }
}

class FinderScreenContent extends StatelessWidget {
  const FinderScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Device finder'),
      body: BlocBuilder<FinderBloc, FinderState>(
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _buildContent(context, state),
                ),
                _buildBottomButton(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, FinderState state) {
    if (state is FinderInitialState) {
      return _buildInitialState(context);
    } else if (state is FinderScanningState) {
      return const ScanningAnimation();
    } else if (state is FinderResultsState) {
      return DeviceList(devices: state.devices);
    } else if (state is FinderErrorState) {
      return _buildErrorState(context, state.message);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.read<FinderBloc>().add(const StartScanningEvent()),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap to scan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(

              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () => context.read<FinderBloc>().add(const StartScanningEvent()),
            child: const Text(
              'Try Again',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, FinderState state) {
    if (state is FinderScanningState) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => context.read<FinderBloc>().add(const StopScanningEvent()),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    } else if (state is FinderResultsState) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => context.read<FinderBloc>().add(const StartScanningEvent()),
            child: const Text(
              'Refresh',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }
    
    return const SizedBox(height: 16);
  }
}
