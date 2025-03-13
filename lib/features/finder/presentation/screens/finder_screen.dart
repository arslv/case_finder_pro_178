import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pod_finder_pro_178/core/package/uwb/lib/flutter_uwb.dart';
import 'package:pod_finder_pro_178/core/widgets/app_bar.dart';
import 'package:pod_finder_pro_178/core/widgets/app_button.dart';
import 'package:pod_finder_pro_178/features/finder/presentation/widgets/search_animation.dart';

class FinderScreen extends StatefulWidget {
  const FinderScreen({super.key});

  @override
  State<FinderScreen> createState() => _FinderScreenState();
}

class _FinderScreenState extends State<FinderScreen> {
  final _uwbPlugin = Uwb();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initUwb();
  }

  Future<void> _initUwb() async {
    try {
      final isSupported = await _uwbPlugin.isUwbSupported();
      if (isSupported) {
        _startSearch();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _startSearch() async {
    try {
      await _uwbPlugin.discoverDevices("Your Device Name");
      setState(() => _isSearching = true);

      _uwbPlugin.discoveryStateStream.listen((event) {
        // Handle discovery events
        print('Discovery event: $event');
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopSearch() async {
    await _uwbPlugin.stopDiscovery();
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CustomAppBar(title: 'Finder'),
      child: SafeArea(
        child: Column(
          children: [
            const Expanded(child: SearchAnimation()),
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                text: _isSearching ? 'Stop Search' : 'Start Search',
                onPressed: _isSearching ? _stopSearch : _startSearch,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _uwbPlugin.stopDiscovery();
    super.dispose();
  }
}
