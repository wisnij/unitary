/// Checks the Google Play store listing against Play's requirements.
///
/// The listing lives under [storeListingRoot], one of the locations F-Droid
/// reads metadata from in an app's source repository, in the same layout as
/// fastlane's `fastlane/metadata/android/<locale>/`: three text files and an
/// `images/` folder holding the icon, the feature graphic, and one folder of
/// screenshots per device type.  The
/// limits here follow Play's help page on preview assets as read on September
/// 29, 2026.  The test suite runs [checkStoreListing] against the committed
/// tree, so a listing that breaks a rule fails CI.
library;

import 'dart:io';
import 'dart:typed_data';

/// The store listing's directory, relative to the repository root.
const String storeListingRoot = 'metadata/en-US';

/// The fields of a PNG file's `IHDR` chunk that the checks need.
final class PngInfo {
  const PngInfo({
    required this.width,
    required this.height,
    required this.bitDepth,
    required this.colorType,
  });

  final int width;
  final int height;

  /// Bits per sample: 8 for ordinary 24-bit RGB or 32-bit RGBA images.
  final int bitDepth;

  /// The PNG colour type: 0 greyscale, 2 RGB, 3 palette, 4 greyscale with
  /// alpha, 6 RGBA.
  final int colorType;

  /// Whether the image has an alpha channel.
  bool get hasAlpha => colorType == 4 || colorType == 6;
}

const List<int> _pngSignature = [137, 80, 78, 71, 13, 10, 26, 10];

/// Reads the size and colour format of a PNG from its first bytes.
///
/// Only the signature and the `IHDR` chunk, which must come first, are read.
/// Throws [FormatException] when [bytes] are not a PNG or end before `IHDR`
/// does.
PngInfo readPngInfo(List<int> bytes) {
  if (bytes.length < 26) {
    throw const FormatException('not a PNG file: too short');
  }
  for (var i = 0; i < _pngSignature.length; i++) {
    if (bytes[i] != _pngSignature[i]) {
      throw const FormatException('not a PNG file: bad signature');
    }
  }
  if (String.fromCharCodes(bytes.sublist(12, 16)) != 'IHDR') {
    throw const FormatException('not a PNG file: first chunk is not IHDR');
  }
  final data = ByteData.sublistView(Uint8List.fromList(bytes.sublist(16, 26)));
  return PngInfo(
    width: data.getUint32(0),
    height: data.getUint32(4),
    bitDepth: data.getUint8(8),
    colorType: data.getUint8(9),
  );
}

/// The store text fields and their limits.
enum TextRule {
  title('title.txt', 30, singleLine: true),
  shortDescription('short_description.txt', 80, singleLine: true),
  fullDescription('full_description.txt', 4000, singleLine: false);

  const TextRule(this.fileName, this.limit, {required this.singleLine});

  /// The file holding this field, relative to [storeListingRoot].
  final String fileName;

  /// The most characters Play accepts.
  final int limit;

  /// Whether the field must fit on one line.
  final bool singleLine;
}

/// Checks [text] against [rule] and returns a description of each problem.
///
/// Trailing line breaks are ignored, as a text file normally ends with one.
/// Length is counted in Unicode characters (runes), not bytes or UTF-16 code
/// units, so `•` or an emoji counts once.
List<String> checkText(TextRule rule, String text) {
  final content = text.replaceFirst(RegExp(r'[\r\n]+$'), '');
  if (content.trim().isEmpty) {
    return ['is empty'];
  }
  final problems = <String>[];
  final length = content.runes.length;
  if (length > rule.limit) {
    problems.add('is $length characters; the limit is ${rule.limit}');
  }
  if (rule.singleLine && content.contains(RegExp(r'[\r\n]'))) {
    problems.add('must be one line');
  }
  return problems;
}

/// The image kinds in the listing, each with its own requirements.
enum ImageRule { icon, featureGraphic, phoneScreenshot, tabletScreenshot }

/// Checks an image's size and format against [rule] and returns a description
/// of each problem.
List<String> checkImage(ImageRule rule, PngInfo info) {
  final size = '${info.width}×${info.height}';
  final rgb = info.bitDepth == 8 && info.colorType == 2;
  const rgbProblem = 'must be 8-bit RGB with no alpha channel';

  switch (rule) {
    case ImageRule.icon:
      return [
        if (info.bitDepth != 8 || info.colorType != 6)
          'must be 8-bit RGBA (32-bit PNG with alpha)',
        if (info.width != 512 || info.height != 512)
          'is $size; it must be 512×512',
      ];
    case ImageRule.featureGraphic:
      return [
        if (!rgb) rgbProblem,
        if (info.width != 1024 || info.height != 500)
          'is $size; it must be 1024×500',
      ];
    case ImageRule.phoneScreenshot:
      final short = _short(info);
      final long = _long(info);
      return [
        if (!rgb) rgbProblem,
        if (!_is16By9(info)) 'is $size; it must be 9:16 or 16:9',
        if (short < 1080) 'is $size; the short side must be at least 1080 px',
        if (long > 3840) 'is $size; the long side must be at most 3840 px',
      ];
    case ImageRule.tabletScreenshot:
      return [
        if (!rgb) rgbProblem,
        if (!_is16By9(info)) 'is $size; it must be 9:16 or 16:9',
        if (_short(info) < 1080 || _long(info) > 7680)
          'is $size; each side must be between 1080 and 7680 px',
      ];
  }
}

int _short(PngInfo info) => info.width < info.height ? info.width : info.height;

int _long(PngInfo info) => info.width < info.height ? info.height : info.width;

bool _is16By9(PngInfo info) => _long(info) * 9 == _short(info) * 16;

/// The fewest and most screenshots a set may hold.  Play needs four for each
/// tablet size, and four phone screenshots for the app to be promoted; it
/// shows at most eight per device type.
const int minScreenshots = 4;
const int maxScreenshots = 8;

final RegExp _screenshotName = RegExp(r'^(\d\d)_[^/]+\.png$');

/// Checks the names of the PNG files in one screenshot folder: between
/// [minScreenshots] and [maxScreenshots] files, each named `NN_<name>.png`,
/// with no number used twice.
List<String> checkScreenshotFileNames(List<String> names) {
  final problems = <String>[];
  if (names.length < minScreenshots || names.length > maxScreenshots) {
    problems.add(
      'holds ${names.length} screenshots; Play needs between '
      '$minScreenshots and $maxScreenshots',
    );
  }
  final seen = <String>{};
  for (final name in [...names]..sort()) {
    final match = _screenshotName.firstMatch(name);
    if (match == null) {
      problems.add('$name is not named NN_<name>.png');
    } else if (!seen.add(match.group(1)!)) {
      problems.add('number ${match.group(1)} is used more than once');
    }
  }
  return problems;
}

/// The screenshot folders under `images/` and the rule each one's images
/// follow.
const Map<String, ImageRule> screenshotFolders = {
  'phoneScreenshots': ImageRule.phoneScreenshot,
  'sevenInchScreenshots': ImageRule.tabletScreenshot,
  'tenInchScreenshots': ImageRule.tabletScreenshot,
};

/// The largest icon file Play accepts.
const int maxIconBytes = 1024 * 1024;

/// Checks the whole listing under [root] and returns each problem, prefixed
/// with the path of the file or folder it concerns, relative to [root].
List<String> checkStoreListing(String root) {
  final problems = <String>[];

  for (final rule in TextRule.values) {
    final file = File('$root/${rule.fileName}');
    if (!file.existsSync()) {
      problems.add('${rule.fileName}: missing');
      continue;
    }
    for (final problem in checkText(rule, file.readAsStringSync())) {
      problems.add('${rule.fileName}: $problem');
    }
  }

  void checkImageFile(String path, ImageRule rule) {
    final file = File('$root/$path');
    if (!file.existsSync()) {
      problems.add('$path: missing');
      return;
    }
    final bytes = file.readAsBytesSync();
    final PngInfo info;
    try {
      info = readPngInfo(bytes);
    } on FormatException catch (e) {
      problems.add('$path: ${e.message}');
      return;
    }
    for (final problem in checkImage(rule, info)) {
      problems.add('$path: $problem');
    }
    if (rule == ImageRule.icon && bytes.length > maxIconBytes) {
      problems.add(
        '$path: is ${(bytes.length / 1024).ceil()} KB; '
        'the limit is 1024 KB',
      );
    }
  }

  checkImageFile('images/icon.png', ImageRule.icon);
  checkImageFile('images/featureGraphic.png', ImageRule.featureGraphic);

  for (final MapEntry(key: folder, value: rule) in screenshotFolders.entries) {
    final path = 'images/$folder';
    final dir = Directory('$root/$path');
    if (!dir.existsSync()) {
      problems.add('$path: missing');
      continue;
    }
    final names =
        dir
            .listSync()
            .whereType<File>()
            .map((f) => f.uri.pathSegments.last)
            .where((name) => name.toLowerCase().endsWith('.png'))
            .toList()
          ..sort();
    for (final problem in checkScreenshotFileNames(names)) {
      problems.add('$path: $problem');
    }
    for (final name in names) {
      checkImageFile('$path/$name', rule);
    }
  }

  return problems;
}
