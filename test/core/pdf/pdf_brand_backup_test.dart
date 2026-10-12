import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:powercoach_studio/core/pdf/pdf_brand_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/fake_path_provider_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StableFakePathProvider pathProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    pathProvider = StableFakePathProvider(prefix: 'pdf_brand_backup_');
    PathProviderPlatform.instance = pathProvider;
  });

  test('exportForBackup omits device path and includes logo base64', () async {
    const userId = 'coach-export';
    await PdfBrandStore.instance.write(
      userId,
      const PdfBrandData(
        studioName: 'Studio Alpha',
        accentColorArgb: 0xFF0D59F2,
        disclaimer: 'Footer',
        hidePowerCoachBranding: true,
      ),
    );
    final bytes = Uint8List.fromList(List<int>.generate(32, (i) => i + 1));
    await PdfBrandStore.instance.saveLogo(userId, bytes, extension: 'png');

    final exported = await PdfBrandStore.instance.exportForBackup(userId);
    expect(exported['studioName'], 'Studio Alpha');
    expect(exported['accentColorArgb'], 0xFF0D59F2);
    expect(exported['disclaimer'], 'Footer');
    expect(exported['hidePowerCoachBranding'], isTrue);
    expect(exported.containsKey('logoRelativePath'), isFalse);
    expect(exported['logoExtension'], 'png');
    expect(exported['logoBase64'], base64Encode(bytes));
  });

  test('applyFromBackupMap round-trips metadata and logo', () async {
    const userId = 'coach-apply';
    final bytes = Uint8List.fromList([9, 8, 7, 6, 5, 4]);
    await PdfBrandStore.instance.applyFromBackupMap(
      userId,
      <String, dynamic>{
        'studioName': 'Restored Studio',
        'accentColorArgb': 0xFF112233,
        'disclaimer': 'From backup',
        'hidePowerCoachBranding': true,
        'logoBase64': base64Encode(bytes),
        'logoExtension': 'jpg',
        // Device-local path from an older device must be ignored.
        'logoRelativePath': 'pdf_brand/other/logo.png',
      },
    );

    final meta = await PdfBrandStore.instance.read(userId);
    expect(meta.studioName, 'Restored Studio');
    expect(meta.accentColorArgb, 0xFF112233);
    expect(meta.disclaimer, 'From backup');
    expect(meta.hidePowerCoachBranding, isTrue);
    expect(meta.hasLogo, isTrue);
    expect(meta.logoRelativePath, isNot('pdf_brand/other/logo.png'));

    final loaded = await PdfBrandStore.instance.loadLogoBytes(userId);
    expect(loaded, bytes);
  });

  test('applyFromBackupMap without logo clears existing logo', () async {
    const userId = 'coach-clear-logo';
    final bytes = Uint8List.fromList([1, 2, 3]);
    await PdfBrandStore.instance.write(
      userId,
      const PdfBrandData(studioName: 'Keep name'),
    );
    await PdfBrandStore.instance.saveLogo(userId, bytes, extension: 'png');

    await PdfBrandStore.instance.applyFromBackupMap(
      userId,
      const <String, dynamic>{
        'studioName': 'No logo',
        'hidePowerCoachBranding': false,
      },
    );

    final meta = await PdfBrandStore.instance.read(userId);
    expect(meta.studioName, 'No logo');
    expect(meta.logoRelativePath, isNull);
    expect(await PdfBrandStore.instance.loadLogoBytes(userId), isNull);
  });

  test('exportForBackup skips oversized logo bytes', () async {
    const userId = 'coach-huge';
    await PdfBrandStore.instance.write(
      userId,
      const PdfBrandData(studioName: 'Huge logo'),
    );
    // Native path allows up to maxLogoBytes; backup portable budget is web cap.
    final huge = Uint8List(PdfBrandStore.maxWebLogoBytes + 1);
    await PdfBrandStore.instance.saveLogo(userId, huge, extension: 'png');

    final exported = await PdfBrandStore.instance.exportForBackup(userId);
    expect(exported['studioName'], 'Huge logo');
    expect(exported.containsKey('logoBase64'), isFalse);
    expect(exported.containsKey('logoExtension'), isFalse);
  });
}
