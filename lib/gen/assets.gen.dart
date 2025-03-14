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

  /// File path: assets/vector/case_finder_active.svg
  String get caseFinderActive => 'assets/vector/case_finder_active.svg';

  /// File path: assets/vector/case_finder_inactive.svg
  String get caseFinderInactive => 'assets/vector/case_finder_inactive.svg';

  /// File path: assets/vector/favorites_active.svg
  String get favoritesActive => 'assets/vector/favorites_active.svg';

  /// File path: assets/vector/favorites_inactive.svg
  String get favoritesInactive => 'assets/vector/favorites_inactive.svg';

  /// File path: assets/vector/finder_active.svg
  String get finderActive => 'assets/vector/finder_active.svg';

  /// File path: assets/vector/finder_inactive.svg
  String get finderInactive => 'assets/vector/finder_inactive.svg';

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
        caseFinderActive,
        caseFinderInactive,
        favoritesActive,
        favoritesInactive,
        finderActive,
        finderInactive,
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
