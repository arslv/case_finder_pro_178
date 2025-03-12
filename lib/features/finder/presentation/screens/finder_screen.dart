// import 'package:flutter/cupertino.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/widgets/app_bar.dart';
// import '../bloc/finder_bloc.dart';
// import '../widgets/search_animation.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// class FinderScreen extends StatelessWidget {
//   const FinderScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => FinderBloc(),
//       child: CupertinoPageScaffold(
//         backgroundColor: AppColors.featuresBg,
//         navigationBar: const CustomAppBar(
//           title: 'Finder',
//         ),
//         child: BlocBuilder<FinderBloc, FinderState>(
//           builder: (context, state) {
//             return SafeArea(
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: _buildContent(context, state),
//                   ),
//                   _buildBottomButton(context, state),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildContent(BuildContext context, FinderState state) {
//     if (state is FinderInitial) {
//       return Center(
//         child: CupertinoButton(
//           onPressed: () {
//             context.read<FinderBloc>().add(StartSearching());
//           },
//           child: Image.asset(
//             'assets/images/finder_logo.png',
//             width: 60,
//             height: 60,
//           ),
//         ),
//       );
//     }
//
//     if (state is FinderSearching) {
//       return const Center(
//         child: SearchAnimation(),
//       );
//     }
//
//     if (state is FinderDevicesFound) {
//       if (state.devices.isEmpty) {
//         return const Center(
//           child: Text('No devices found'),
//         );
//       }
//
//       return ListView.builder(
//         itemCount: state.devices.length,
//         itemBuilder: (context, index) {
//           final device = state.devices[index];
//           return Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(
//               color: CupertinoColors.white,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: CupertinoButton(
//               padding: const EdgeInsets.all(16),
//               onPressed: () {
//                 // TODO: Implement device selection
//               },
//               child: Row(
//                 children: [
//                   SvgPicture.asset(
//                     'assets/vector/device.svg',
//                     width: 24,
//                     height: 24,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       device.name,
//                       style: const TextStyle(
//                         color: AppColors.black,
//                         fontSize: 17,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     }
//
//     return const SizedBox.shrink();
//   }
//
//   Widget _buildBottomButton(BuildContext context, FinderState state) {
//     if (state is FinderSearching) {
//       return Padding(
//         padding: const EdgeInsets.all(16),
//         child: SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: CupertinoButton(
//             padding: EdgeInsets.zero,
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(12),
//             onPressed: () {
//               context.read<FinderBloc>().add(StopSearching());
//             },
//             child: const Text('Cancel'),
//           ),
//         ),
//       );
//     }
//
//     if (state is FinderDevicesFound) {
//       return Padding(
//         padding: const EdgeInsets.all(16),
//         child: SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: CupertinoButton(
//             padding: EdgeInsets.zero,
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(12),
//             onPressed: () {
//               context.read<FinderBloc>().add(RefreshDevices());
//             },
//             child: const Text('Refresh'),
//           ),
//         ),
//       );
//     }
//
//     return const SizedBox.shrink();
//   }
// }