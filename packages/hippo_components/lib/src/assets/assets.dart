import 'package:flutter/widgets.dart';

export 'folders/other_assets.dart';

enum HippoAssetType { png, jpg, webp, svg, ogg, mp3, json, html }

class HippoAsset {
  final String path;
  final HippoAssetType type;

  const HippoAsset(this.path, this.type);

  const HippoAsset.png(String path)
    : path = '${HippoAssets.packagePrefix}/assets/$path',
      type = HippoAssetType.png;
  const HippoAsset.jpg(String path)
    : path = '${HippoAssets.packagePrefix}/assets/$path',
      type = HippoAssetType.jpg;
  const HippoAsset.webp(String path)
    : path = '${HippoAssets.packagePrefix}/assets/$path',
      type = HippoAssetType.webp;
  const HippoAsset.svg(String path)
    : path = '${HippoAssets.packagePrefix}/assets/$path',
      type = HippoAssetType.svg;
  const HippoAsset.json(String path)
    : path = '${HippoAssets.packagePrefix}/assets/$path',
      type = HippoAssetType.json;
  const HippoAsset.ogg(String path)
    : path = '${HippoAssets.packagePrefix}/assets/$path',
      type = HippoAssetType.ogg;
  const HippoAsset.mp3(String path)
    : path = '${HippoAssets.packagePrefix}/assets/$path',
      type = HippoAssetType.mp3;
  const HippoAsset.html(String path)
    : path = '${HippoAssets.packagePrefix}/assets/$path',
      type = HippoAssetType.html; // Using html type for HTML as a placeholder

  AssetImage toAssetImage() {
    assert(type != HippoAssetType.svg, 'SVG is not supported');
    return AssetImage(path);
  }
}

class HippoAssets {
  const HippoAssets._();

  static const packagePrefix = 'packages/hippo_components';
}
