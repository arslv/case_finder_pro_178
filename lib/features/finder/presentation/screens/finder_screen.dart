import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uwb/flutter_uwb.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/device/device_interface.dart';
import '../../../../core/device/device_service.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../bloc/finder_bloc.dart';
import '../widgets/device_list.dart';
import '../widgets/error_view.dart';
import '../widgets/search_animation.dart';

class FinderScreen extends StatelessWidget {
  const FinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FinderBloc(
        DeviceRepositoryImpl(
          ServiceLocator.get<DeviceService>(),
        ),
      ),
      child: const CupertinoPageScaffold(
        navigationBar: CustomAppBar(title: 'Finder'),
        child: FinderContent(),
      ),
    );
  }
}

class FinderContent extends StatefulWidget {
  const FinderContent({super.key});

  @override
  State<FinderContent> createState() => _FinderContentState();
}

class _FinderContentState extends State<FinderContent> {
  @override
  void initState() {
    super.initState();
  }

  void _startDiscovery() async {
    HapticFeedback.selectionClick();
    context.read<FinderBloc>().add(const StartDiscovery('iPhone 12 (Арслан)'));
  }

  void _stopDiscovery() {
    HapticFeedback.selectionClick();
    context.read<FinderBloc>().add(StopDiscovery());
  }

  void _connectToDevice(Device device) {
    HapticFeedback.selectionClick();
    context.read<FinderBloc>().add(ConnectToDevice(device));
  }

  void _disconnectFromDevice(Device device) {
    HapticFeedback.selectionClick();
    context.read<FinderBloc>().add(DisconnectFromDevice(device));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<FinderBloc, FinderState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: _buildContent(state),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildButton(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(FinderState state) {
    if (state is FinderInitial) {
      return const Center(
        child: SearchAnimation(),
      );
    } else if (state is FinderLoading) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 20),
      );
    } else if (state is FinderDiscovering) {
      return Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Searching for devices...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DeviceList(
              devices: state.devices,
              onDeviceSelected: _connectToDevice,
              isConnecting: state.isConnecting,
            ),
          ),
        ],
      );
    } else if (state is FinderConnected) {
      return Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Connected to ${state.device.name}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.activeGreen,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DeviceList(
              devices: state.allDevices,
              connectedDevice: state.device,
              onDeviceSelected: (device) {
                if (device.id == state.device.id) {
                  _disconnectFromDevice(device);
                } else {
                  _connectToDevice(device);
                }
              },
            ),
          ),
        ],
      );
    } else if (state is FinderError) {
      return ErrorView(
        message: state.message,
        onRetry: _startDiscovery,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildButton(FinderState state) {
    if (state is FinderInitial) {
      return AppButton(
        text: 'Start Search',
        onPressed: _startDiscovery,
      );
    } else if (state is FinderDiscovering || state is FinderConnected) {
      return AppButton(
        text: 'Stop Search',
        onPressed: _stopDiscovery,
      );
    } else if (state is FinderLoading) {
      return AppButton(
        text: 'Searching...',
        onPressed: () {},
        backgroundColor: CupertinoColors.systemGrey,
      );
    }

    return AppButton(
      text: 'Start Search',
      onPressed: _startDiscovery,
    );
  }
}
