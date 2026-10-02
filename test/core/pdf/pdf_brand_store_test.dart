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
    pathProvider = StableFakePathProvider(prefix: 'pdf_brand_store_');
    PathProviderPlatform.instance = pathProvider;
  });

  test('write/read round-trips brand metadata', () async {
    const userId = 'coach-1';
    const data = PdfBrandData(
      studioName: 'Studio Alpha',
      accentColorArgb: 0xFF0D59F2,
      disclaimer: 'Custom footer',
      hidePowerCoachBranding: true,
    );

    await PdfBrandStore.instance.write(userId, data);
    final loaded = await PdfBrandStore.instance.read(userId);

    expect(loaded.studioName, 'Studio Alpha');
    expect(loaded.accentColorArgb, 0xFF0D59F2);
    expect(loaded.disclaimer, 'Custom footer');
    expect(loaded.hidePowerCoachBranding, isTrue);
    expect(loaded.logoRelativePath, isNull);
  });

  test('empty userId returns defaults and skips write', () async {
    await PdfBrandStore.instance.write(
      '',
      const PdfBrandData(studioName: 'Nope'),
    );
    final loaded = await PdfBrandStore.instance.read('');
    expect(loaded.studioName, isEmpty);
  });

  test('saveLogo + loadLogoBytes persists logo on native path', () async {
    const userId = 'coach-logo';
    final bytes = Uint8List.fromList(List<int>.generate(64, (i) => i));

    final saved = await PdfBrandStore.instance.saveLogo(
      userId,
      bytes,
      extension: 'png',
    );
    expect(saved.hasLogo, isTrue);
    expect(saved.logoRelativePath, contains('pdf_brand/$userId/logo.png'));

    final loadedBytes = await PdfBrandStore.instance.loadLogoBytes(userId);
    expect(loadedBytes, isNotNull);
    expect(loadedBytes, bytes);

    final meta = await PdfBrandStore.instance.read(userId);
    expect(meta.logoRelativePath, saved.logoRelativePath);
  });

  test('clearLogo removes bytes and path', () async {
    const userId = 'coach-clear';
    final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    await PdfBrandStore.instance.saveLogo(userId, bytes, extension: 'jpg');
    await PdfBrandStore.instance.clearLogo(userId);

    final meta = await PdfBrandStore.instance.read(userId);
    expect(meta.logoRelativePath, isNull);
    expect(await PdfBrandStore.instance.loadLogoBytes(userId), isNull);
  });

  test('saveLogo rejects oversized payloads', () async {
    final huge = Uint8List(PdfBrandStore.maxLogoBytes + 1);
    expect(
      () => PdfBrandStore.instance.saveLogo('u', huge),
      throwsA(isA<PdfBrandLogoTooLargeException>()),
    );
  });

  test('fromJson tolerates missing optional fields', () {
    final data = PdfBrandData.fromJson(const <String, dynamic>{});
    expect(data.studioName, isEmpty);
    expect(data.accentColorArgb, isNull);
    expect(data.hidePowerCoachBranding, isFalse);
  });
}
