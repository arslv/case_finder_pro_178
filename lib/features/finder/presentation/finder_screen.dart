import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pod_finder_pro_178/core/package/uwb/lib/flutter_uwb.dart' as uwb_package;
import 'package:pod_finder_pro_178/core/package/uwb/pigeons/uwb.dart'; // Используем UwbDevice из pigeons
import 'package:pod_finder_pro_178/core/widgets/app_bar.dart';
import 'package:pod_finder_pro_178/core/widgets/app_button.dart';
import 'package:pod_finder_pro_178/core/widgets/pro_button.dart';
import '../../../core/theme/app_colors.dart';
import 'bloc/finder_bloc.dart';
import 'widgets/search_animation.dart';

class FinderScreen extends StatelessWidget {
  const FinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FinderBloc(),
      child: Scaffold(
        body: Container(
          color: AppColors.featuresBg,
          width: double.infinity,
          child: Column(
            children: [
              CustomAppBar(
                title: 'Finder',
                suffix: ProButton(),
              ),
              Expanded(
                child: BlocBuilder<FinderBloc, FinderState>(
                  builder: (context, state) {
                    if (state is FinderSearching) {
                      return const Center(child: SearchAnimation());
                    }
                    //
                    // if (state is FinderDevicesFound) {
                    //   return _buildDeviceList(context, state.devices);
                    // }

                    if (state is FinderError) {
                      return Center(child: Text(state.message));
                    }

                    return Center(
                      child: AppButton(
                        text: 'Start Search',
                        onPressed: () {
                          context.read<FinderBloc>().add(StartSearching());
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context, List<UwbDevice> devices) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: devices.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final device = devices[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(device.name ?? 'Unknown Device'),
                  subtitle: Text('ID: ${device.id}'), // Используем только доступные поля
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            text: 'Stop Search',
            onPressed: () {
              context.read<FinderBloc>().add(StopSearching());
            },
          ),
        ),
      ],
    );
  }
}
