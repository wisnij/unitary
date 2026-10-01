import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_store_listing_lib.dart';

/// The bytes of a PNG file up to the end of its `IHDR` chunk, which is all
/// [readPngInfo] reads.  [colorType] 2 is RGB and 6 is RGBA.
Uint8List pngHeader(
  int width,
  int height, {
  int bitDepth = 8,
  int colorType = 2,
}) {
  final data = ByteData(33);
  const signature = [137, 80, 78, 71, 13, 10, 26, 10];
  for (var i = 0; i < signature.length; i++) {
    data.setUint8(i, signature[i]);
  }
  data.setUint32(8, 13); // IHDR data length
  const ihdr = 'IHDR';
  for (var i = 0; i < 4; i++) {
    data.setUint8(12 + i, ihdr.codeUnitAt(i));
  }
  data.setUint32(16, width);
  data.setUint32(20, height);
  data.setUint8(24, bitDepth);
  data.setUint8(25, colorType);
  // Compression, filter, interlace, and CRC stay zero; they are not read.
  return data.buffer.asUint8List();
}

PngInfo rgb(int width, int height) =>
    PngInfo(width: width, height: height, bitDepth: 8, colorType: 2);

PngInfo rgba(int width, int height) =>
    PngInfo(width: width, height: height, bitDepth: 8, colorType: 6);

void main() {
  group('readPngInfo', () {
    test('reads width, height, bit depth, and colour type', () {
      final info = readPngInfo(pngHeader(1080, 1920, colorType: 6));

      expect(info.width, 1080);
      expect(info.height, 1920);
      expect(info.bitDepth, 8);
      expect(info.colorType, 6);
    });

    test('reads dimensions above 16 bits', () {
      final info = readPngInfo(pngHeader(70000, 3));

      expect(info.width, 70000);
    });

    test('reports an alpha channel for colour types 4 and 6 only', () {
      for (final (type, alpha) in [
        (0, false),
        (2, false),
        (3, false),
        (4, true),
        (6, true),
      ]) {
        expect(
          readPngInfo(pngHeader(1, 1, colorType: type)).hasAlpha,
          alpha,
          reason: 'colour type $type',
        );
      }
    });

    test('rejects bytes without the PNG signature', () {
      final bytes = pngHeader(1, 1)..[0] = 0xFF;

      expect(() => readPngInfo(bytes), throwsFormatException);
    });

    test('rejects a file truncated before the end of IHDR', () {
      expect(
        () => readPngInfo(pngHeader(1, 1).sublist(0, 20)),
        throwsFormatException,
      );
    });

    test('rejects a file whose first chunk is not IHDR', () {
      final bytes = pngHeader(1, 1)..[12] = 'X'.codeUnitAt(0);

      expect(() => readPngInfo(bytes), throwsFormatException);
    });
  });

  group('checkText', () {
    test('accepts text at the limit', () {
      expect(checkText(TextRule.title, 'a' * 30), isEmpty);
      expect(checkText(TextRule.shortDescription, 'a' * 80), isEmpty);
      expect(checkText(TextRule.fullDescription, 'a' * 4000), isEmpty);
    });

    test('rejects text one character over the limit', () {
      expect(checkText(TextRule.title, 'a' * 31), [contains('31')]);
      expect(checkText(TextRule.shortDescription, 'a' * 81), [contains('80')]);
      expect(
        checkText(TextRule.fullDescription, 'a' * 4001),
        [contains('4000')],
      );
    });

    test('counts a multi-byte character once', () {
      expect(checkText(TextRule.shortDescription, '•' * 80), isEmpty);
      expect(checkText(TextRule.shortDescription, '–' * 81), isNotEmpty);
    });

    test('counts a character outside the BMP once', () {
      expect(checkText(TextRule.title, '😀' * 30), isEmpty);
    });

    test('ignores trailing newlines', () {
      expect(checkText(TextRule.title, '${'a' * 30}\n'), isEmpty);
      expect(checkText(TextRule.title, '${'a' * 30}\r\n'), isEmpty);
    });

    test('rejects a line break in the title and short description', () {
      expect(checkText(TextRule.title, 'a\nb'), [contains('one line')]);
      expect(
        checkText(TextRule.shortDescription, 'a\nb'),
        [contains('one line')],
      );
    });

    test('allows line breaks in the full description', () {
      expect(checkText(TextRule.fullDescription, 'a\n\nb\n• c'), isEmpty);
    });

    test('rejects empty or blank text', () {
      for (final rule in TextRule.values) {
        expect(checkText(rule, ''), [contains('empty')], reason: '$rule');
        expect(checkText(rule, ' \n'), [contains('empty')], reason: '$rule');
      }
    });
  });

  group('checkImage: icon', () {
    test('accepts a 512×512 RGBA image', () {
      expect(checkImage(ImageRule.icon, rgba(512, 512)), isEmpty);
    });

    test('rejects the wrong size', () {
      expect(checkImage(ImageRule.icon, rgba(1024, 1024)), [contains('512')]);
    });

    test('rejects an image without alpha', () {
      expect(checkImage(ImageRule.icon, rgb(512, 512)), [contains('RGBA')]);
    });

    test('rejects 16-bit colour', () {
      const info = PngInfo(width: 512, height: 512, bitDepth: 16, colorType: 6);

      expect(checkImage(ImageRule.icon, info), [contains('RGBA')]);
    });
  });

  group('checkImage: feature graphic', () {
    test('accepts a 1024×500 RGB image', () {
      expect(checkImage(ImageRule.featureGraphic, rgb(1024, 500)), isEmpty);
    });

    test('rejects the wrong size', () {
      expect(
        checkImage(ImageRule.featureGraphic, rgb(1024, 512)),
        [contains('1024×500')],
      );
    });

    test('rejects an alpha channel', () {
      expect(
        checkImage(ImageRule.featureGraphic, rgba(1024, 500)),
        [contains('alpha')],
      );
    });
  });

  group('checkImage: phone screenshot', () {
    test('accepts 9:16 and 16:9 at 1080×1920', () {
      expect(checkImage(ImageRule.phoneScreenshot, rgb(1080, 1920)), isEmpty);
      expect(checkImage(ImageRule.phoneScreenshot, rgb(1920, 1080)), isEmpty);
    });

    test('accepts the largest 9:16 size within 3840 px', () {
      expect(checkImage(ImageRule.phoneScreenshot, rgb(2160, 3840)), isEmpty);
    });

    test('rejects other aspect ratios', () {
      expect(
        checkImage(ImageRule.phoneScreenshot, rgb(1440, 3120)),
        [contains('9:16')],
      );
    });

    test('rejects a short side below 1080 px', () {
      expect(
        checkImage(ImageRule.phoneScreenshot, rgb(720, 1280)),
        [contains('1080')],
      );
    });

    test('rejects a long side above 3840 px', () {
      expect(
        checkImage(ImageRule.phoneScreenshot, rgb(2250, 4000)),
        [contains('3840')],
      );
    });

    test('rejects an alpha channel', () {
      expect(
        checkImage(ImageRule.phoneScreenshot, rgba(1080, 1920)),
        [contains('alpha')],
      );
    });
  });

  group('checkImage: tablet screenshot', () {
    test('accepts 9:16 and 16:9 within 1080–7680 px', () {
      expect(checkImage(ImageRule.tabletScreenshot, rgb(1080, 1920)), isEmpty);
      expect(checkImage(ImageRule.tabletScreenshot, rgb(2560, 1440)), isEmpty);
      expect(checkImage(ImageRule.tabletScreenshot, rgb(7680, 4320)), isEmpty);
    });

    test('rejects 16:10', () {
      expect(
        checkImage(ImageRule.tabletScreenshot, rgb(2560, 1600)),
        [contains('9:16')],
      );
    });

    test('rejects a side below 1080 px', () {
      expect(
        checkImage(ImageRule.tabletScreenshot, rgb(1024, 576)),
        [contains('1080')],
      );
    });

    test('rejects a side above 7680 px', () {
      expect(
        checkImage(ImageRule.tabletScreenshot, rgb(8000, 4500)),
        [contains('7680')],
      );
    });

    test('reports every problem at once', () {
      expect(checkImage(ImageRule.tabletScreenshot, rgba(2560, 1600)), [
        contains('alpha'),
        contains('9:16'),
      ]);
    });
  });

  group('checkScreenshotFileNames', () {
    test('accepts four to eight numbered PNG files', () {
      expect(
        checkScreenshotFileNames([
          '01_freeform.png',
          '02_worksheet.png',
          '03_currency.png',
          '04_browser.png',
        ]),
        isEmpty,
      );
      expect(
        checkScreenshotFileNames([
          for (var i = 1; i <= 8; i++) '0${i}_shot.png',
        ]),
        isEmpty,
      );
    });

    test('rejects fewer than four or more than eight', () {
      expect(
        checkScreenshotFileNames(['01_a.png', '02_b.png', '03_c.png']),
        [contains('3')],
      );
      expect(
        checkScreenshotFileNames([
          for (var i = 1; i <= 9; i++) '0${i}_shot.png',
        ]),
        [contains('9')],
      );
    });

    test('rejects a name not of the form NN_name.png', () {
      expect(
        checkScreenshotFileNames([
          '01_a.png',
          '02_b.png',
          '03_c.png',
          'worksheet.png',
        ]),
        [contains('worksheet.png')],
      );
    });

    test('rejects two files with the same number', () {
      expect(
        checkScreenshotFileNames([
          '01_a.png',
          '02_b.png',
          '03_c.png',
          '03_d.png',
        ]),
        [contains('03')],
      );
    });
  });

  group('checkStoreListing', () {
    late Directory root;

    setUp(() {
      root = Directory.systemTemp.createTempSync('store_listing');
    });

    tearDown(() {
      root.deleteSync(recursive: true);
    });

    void write(String path, List<int> bytes) {
      File('${root.path}/$path')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes);
    }

    void writeText(String path, String text) {
      File('${root.path}/$path')
        ..createSync(recursive: true)
        ..writeAsStringSync(text);
    }

    void writeValidTree() {
      writeText('title.txt', 'Unitary: Unit Converter\n');
      writeText('short_description.txt', 'A unit converter.\n');
      writeText('full_description.txt', 'Converts units.\n');
      write('images/icon.png', pngHeader(512, 512, colorType: 6));
      write('images/featureGraphic.png', pngHeader(1024, 500));
      for (var i = 1; i <= 4; i++) {
        write('images/phoneScreenshots/0${i}_s.png', pngHeader(1080, 1920));
        write('images/sevenInchScreenshots/0${i}_s.png', pngHeader(1080, 1920));
        write('images/tenInchScreenshots/0${i}_s.png', pngHeader(2560, 1440));
      }
    }

    test('reports nothing for a valid tree', () {
      writeValidTree();

      expect(checkStoreListing(root.path), isEmpty);
    });

    test('reports a missing file by path', () {
      writeValidTree();
      File('${root.path}/images/featureGraphic.png').deleteSync();

      expect(checkStoreListing(root.path), [
        allOf(contains('images/featureGraphic.png'), contains('missing')),
      ]);
    });

    test('reports a missing screenshot folder', () {
      writeValidTree();
      Directory(
        '${root.path}/images/tenInchScreenshots',
      ).deleteSync(recursive: true);

      expect(checkStoreListing(root.path), [
        allOf(contains('images/tenInchScreenshots'), contains('missing')),
      ]);
    });

    test('names the file for each image problem', () {
      writeValidTree();
      write('images/sevenInchScreenshots/02_s.png', pngHeader(2560, 1600));

      expect(checkStoreListing(root.path), [
        allOf(
          contains('images/sevenInchScreenshots/02_s.png'),
          contains('9:16'),
        ),
      ]);
    });

    test('checks phone screenshots against the phone rule', () {
      writeValidTree();
      // Valid for a tablet but not a phone: the long side is above 3840 px.
      write('images/phoneScreenshots/01_s.png', pngHeader(4320, 7680));

      expect(checkStoreListing(root.path), [contains('3840')]);
    });

    test('names the file for each text problem', () {
      writeValidTree();
      writeText('short_description.txt', 'a' * 81);

      expect(checkStoreListing(root.path), [
        allOf(contains('short_description.txt'), contains('80')),
      ]);
    });

    test('reports a file that is not a PNG', () {
      writeValidTree();
      writeText('images/icon.png', 'not an image');

      expect(checkStoreListing(root.path), [
        allOf(contains('images/icon.png'), contains('PNG')),
      ]);
    });

    test('rejects an icon over 1024 KB', () {
      writeValidTree();
      write('images/icon.png', [
        ...pngHeader(512, 512, colorType: 6),
        ...List.filled(1024 * 1024, 0),
      ]);

      expect(checkStoreListing(root.path), [
        allOf(contains('images/icon.png'), contains('1024 KB')),
      ]);
    });

    test('ignores files other than PNGs in screenshot folders', () {
      writeValidTree();
      writeText('images/phoneScreenshots/.gitkeep', '');

      expect(checkStoreListing(root.path), isEmpty);
    });
  });

  group('committed store listing', () {
    test('meets every rule', () {
      expect(checkStoreListing(storeListingRoot), isEmpty);
    });

    test('has the agreed title', () {
      expect(
        File('$storeListingRoot/title.txt').readAsStringSync().trimRight(),
        'Unitary: Unit Converter',
      );
    });
  });
}
