/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/SF-Pro-Text-Semibold.otf
  String get sFProTextSemibold => 'assets/fonts/SF-Pro-Text-Semibold.otf';

  /// File path: assets/fonts/SF-Pro.ttf
  String get sFPro => 'assets/fonts/SF-Pro.ttf';

  /// List of all assets
  List<String> get values => [sFProTextSemibold, sFPro];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/finder_logo.png
  AssetGenImage get finderLogo =>
      const AssetGenImage('assets/images/finder_logo.png');

  /// File path: assets/images/onb_1.png
  AssetGenImage get onb1 => const AssetGenImage('assets/images/onb_1.png');

  /// File path: assets/images/onb_2.png
  AssetGenImage get onb2 => const AssetGenImage('assets/images/onb_2.png');

  /// File path: assets/images/onb_3.png
  AssetGenImage get onb3 => const AssetGenImage('assets/images/onb_3.png');

  /// File path: assets/images/onb_4.png
  AssetGenImage get onb4 => const AssetGenImage('assets/images/onb_4.png');

  /// List of all assets
  List<AssetGenImage> get values => [finderLogo, onb1, onb2, onb3, onb4];
}

class $AssetsVectorGen {
  const $AssetsVectorGen();

  /// File path: assets/vector/airpods.svg
  String get airpods => 'assets/vector/airpods.svg';

  /// File path: assets/vector/airpods_max.svg
  String get airpodsMax => 'assets/vector/airpods_max.svg';

  /// File path: assets/vector/airpods_pro.svg
  String get airpodsPro => 'assets/vector/airpods_pro.svg';

  /// File path: assets/vector/blue_logo.svg
  String get blueLogo => 'assets/vector/blue_logo.svg';

  /// File path: assets/vector/case_finder_active.svg
  String get caseFinderActive => 'assets/vector/case_finder_active.svg';

  /// File path: assets/vector/case_finder_inactive.svg
  String get caseFinderInactive => 'assets/vector/case_finder_inactive.svg';

  /// File path: assets/vector/crosshair.svg
  String get crosshair => 'assets/vector/crosshair.svg';

  /// File path: assets/vector/exit.svg
  String get exit => 'assets/vector/exit.svg';

  /// File path: assets/vector/exit_round.svg
  String get exitRound => 'assets/vector/exit_round.svg';

  /// File path: assets/vector/favorites_active.svg
  String get favoritesActive => 'assets/vector/favorites_active.svg';

  /// File path: assets/vector/favorites_active_page.svg
  String get favoritesActivePage => 'assets/vector/favorites_active_page.svg';

  /// File path: assets/vector/favorites_inactive.svg
  String get favoritesInactive => 'assets/vector/favorites_inactive.svg';

  /// File path: assets/vector/favorites_inactive_page.svg
  String get favoritesInactivePage =>
      'assets/vector/favorites_inactive_page.svg';

  /// File path: assets/vector/finder_active.svg
  String get finderActive => 'assets/vector/finder_active.svg';

  /// File path: assets/vector/finder_inactive.svg
  String get finderInactive => 'assets/vector/finder_inactive.svg';

  /// File path: assets/vector/help_airpods.svg
  String get helpAirpods => 'assets/vector/help_airpods.svg';

  /// File path: assets/vector/help_battery.svg
  String get helpBattery => 'assets/vector/help_battery.svg';

  /// File path: assets/vector/help_blue.svg
  String get helpBlue => 'assets/vector/help_blue.svg';

  /// File path: assets/vector/help_blue_2.svg
  String get helpBlue2 => 'assets/vector/help_blue_2.svg';

  /// File path: assets/vector/help_moving.svg
  String get helpMoving => 'assets/vector/help_moving.svg';

  /// File path: assets/vector/info.svg
  String get info => 'assets/vector/info.svg';

  /// File path: assets/vector/map_active.svg
  String get mapActive => 'assets/vector/map_active.svg';

  /// File path: assets/vector/map_inactive.svg
  String get mapInactive => 'assets/vector/map_inactive.svg';

  /// File path: assets/vector/pro.svg
  String get pro => 'assets/vector/pro.svg';

  /// File path: assets/vector/settings_active.svg
  String get settingsActive => 'assets/vector/settings_active.svg';

  /// File path: assets/vector/settings_inactive.svg
  String get settingsInactive => 'assets/vector/settings_inactive.svg';

  /// List of all assets
  List<String> get values => [
        airpods,
        airpodsMax,
        airpodsPro,
        blueLogo,
        caseFinderActive,
        caseFinderInactive,
        crosshair,
        exit,
        exitRound,
        favoritesActive,
        favoritesActivePage,
        favoritesInactive,
        favoritesInactivePage,
        finderActive,
        finderInactive,
        helpAirpods,
        helpBattery,
        helpBlue,
        helpBlue2,
        helpMoving,
        info,
        mapActive,
        mapInactive,
        pro,
        settingsActive,
        settingsInactive
      ];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsVectorGen vector = $AssetsVectorGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
