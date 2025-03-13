// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import '../../../core/di/service_locator.dart';
// import '../../../core/package/uwb/lib/src/uwb.dart';
// import '../../../core/widgets/app_bar.dart';
// import '../../../core/widgets/app_button.dart';
// import 'widgets/search_animation.dart';
//
// class FinderScreen extends StatefulWidget {
//   const FinderScreen({super.key});
//
//   @override
//   State<FinderScreen> createState() => _FinderScreenState();
// }
//
// class _FinderScreenState extends State<FinderScreen> {
//   final _uwbPlugin = ServiceLocator.get<Uwb>();
//
//   @override
//   void initState() {
//     super.initState();
//     _startSearch();
//   }
//
//   Future<void> _startSearch() async {
//     try {
//       await _uwbPlugin.discoverDevices("Your Device Name");
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CupertinoPageScaffold(
//       navigationBar: const CustomAppBar(
//         title: 'Finder',
//       ),
//       child: SafeArea(
//         child: Column(
//           children: [
//             const Expanded(
//               child: Center(
//                 child: SearchAnimation(),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: AppButton(
//                 text: 'Stop Search',
//                 onPressed: () {
//                   _uwbPlugin.stopDiscovery();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _uwbPlugin.stopDiscovery();
//     super.dispose();
//   }
// }
