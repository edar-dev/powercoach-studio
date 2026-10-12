import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backup/material_write_notifier.dart';
import 'pdf_brand_logo_stub.dart'
    if (dart.library.io) 'pdf_brand_logo_io.dart' as brand_logo;

/// Thrown when a logo exceeds the allowed byte budget.
class PdfBrandLogoTooLargeException implements Exception {
  PdfBrandLogoTooLargeException(this.maxBytes);

  final int maxBytes;

  @override
  String toString() =>
      'PdfBrandLogoTooLargeException: logo exceeds $maxBytes bytes';
}

/// Coach PDF brand kit stored per authenticated user (device-local logo).
class PdfBrandData {
  const PdfBrandData({
    this.studioName = '',
    this.accentColorArgb,
    this.disclaimer = '',
    this.hidePowerCoachBranding = false,
    this.logoRelativePath,
  });

  final String studioName;
  final int? accentColorArgb;
  final String disclaimer;
  final bool hidePowerCoachBranding;

  /// Relative path under app documents, or `web/logo.<ext>` marker on web.
  final String? logoRelativePath;

  bool get hasLogo =>
      logoRelativePath != null && logoRelativePath!.trim().isNotEmpty;

  PdfBrandData copyWith({
    String? studioName,
    int? accentColorArgb,
    bool clearAccentColor = false,
    String? disclaimer,
    bool? hidePowerCoachBranding,
    String? logoRelativePath,
    bool clearLogoRelativePath = false,
  }) {
    return PdfBrandData(
      studioName: studioName ?? this.studioName,
      accentColorArgb:
          clearAccentColor ? null : (accentColorArgb ?? this.accentColorArgb),
      disclaimer: disclaimer ?? this.disclaimer,
      hidePowerCoachBranding:
          hidePowerCoachBranding ?? this.hidePowerCoachBranding,
      logoRelativePath: clearLogoRelativePath
          ? null
          : (logoRelativePath ?? this.logoRelativePath),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'studioName': studioName,
        'accentColorArgb': accentColorArgb,
        'disclaimer': disclaimer,
        'hidePowerCoachBranding': hidePowerCoachBranding,
        'logoRelativePath': logoRelativePath,
      };

  factory PdfBrandData.fromJson(Map<String, dynamic> json) {
    final accentRaw = json['accentColorArgb'];
    int? accent;
    if (accentRaw is int) {
      accent = accentRaw;
    } else if (accentRaw is num) {
      accent = accentRaw.toInt();
    }
    final path = json['logoRelativePath']?.toString().trim();
    return PdfBrandData(
      studioName: json['studioName']?.toString() ?? '',
      accentColorArgb: accent,
      disclaimer: json['disclaimer']?.toString() ?? '',
      hidePowerCoachBranding: json['hidePowerCoachBranding'] == true,
      logoRelativePath: (path == null || path.isEmpty) ? null : path,
    );
  }
}

class PdfBrandStore {
  PdfBrandStore._();

  static final PdfBrandStore instance = PdfBrandStore._();

  static const metaKeyPrefix = 'pdf_brand_v1';
  static const logoBytesKeyPrefix = 'pdf_brand_logo_bytes_v1';
  static const logoExtKeyPrefix = 'pdf_brand_logo_ext_v1';

  /// Hard cap for logo file size (~1.5 MB).
  static const maxLogoBytes = 1572864;

  /// Soft budget for base64-in-prefs logo storage on web (~500 KB raw).
  static const maxWebLogoBytes = 512000;

  String _metaKey(String userId) => '$metaKeyPrefix:$userId';
  String _logoBytesKey(String userId) => '$logoBytesKeyPrefix:$userId';
  String _logoExtKey(String userId) => '$logoExtKeyPrefix:$userId';

  Future<PdfBrandData> read(String userId) async {
    if (userId.isEmpty) return const PdfBrandData();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_metaKey(userId));
    if (raw == null || raw.isEmpty) return const PdfBrandData();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return const PdfBrandData();
      return PdfBrandData.fromJson(decoded.cast<String, dynamic>());
    } catch (_) {
      return const PdfBrandData();
    }
  }

  Future<void> write(String userId, PdfBrandData data) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_metaKey(userId), jsonEncode(data.toJson()));
    MaterialWriteNotifier.notify();
  }

  Future<PdfBrandData> saveLogo(
    String userId,
    Uint8List bytes, {
    String extension = 'png',
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'must not be empty');
    }
    final ext = _normalizeExtension(extension);
    if (bytes.length > maxLogoBytes) {
      throw PdfBrandLogoTooLargeException(maxLogoBytes);
    }

    if (kIsWeb) {
      if (bytes.length > maxWebLogoBytes) {
        throw PdfBrandLogoTooLargeException(maxWebLogoBytes);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_logoBytesKey(userId), base64Encode(bytes));
      await prefs.setString(_logoExtKey(userId), ext);
      final next = (await read(userId)).copyWith(
        logoRelativePath: 'web/logo.$ext',
      );
      await write(userId, next);
      return next;
    }

    final relative = await brand_logo.writePdfBrandLogoFile(
      userId: userId,
      bytes: bytes,
      extension: ext,
    );
    // Clear any leftover web prefs if present.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logoBytesKey(userId));
    await prefs.remove(_logoExtKey(userId));
    final next =
        (await read(userId)).copyWith(logoRelativePath: relative);
    await write(userId, next);
    return next;
  }

  Future<PdfBrandData> clearLogo(String userId) async {
    if (userId.isEmpty) return const PdfBrandData();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logoBytesKey(userId));
    await prefs.remove(_logoExtKey(userId));
    if (!kIsWeb) {
      await brand_logo.clearPdfBrandLogoFiles(userId);
    }
    final next =
        (await read(userId)).copyWith(clearLogoRelativePath: true);
    await write(userId, next);
    return next;
  }

  Future<Uint8List?> loadLogoBytes(String userId) async {
    if (userId.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_logoBytesKey(userId));
    if (encoded != null && encoded.isNotEmpty) {
      try {
        return base64Decode(encoded);
      } catch (_) {
        return null;
      }
    }
    if (kIsWeb) return null;
    final data = await read(userId);
    final path = data.logoRelativePath;
    if (path == null || path.isEmpty) return null;
    return brand_logo.readPdfBrandLogoFile(path);
  }

  /// Portable brand payload for the user backup envelope (`pdfBrand` key).
  ///
  /// Omits device-local [PdfBrandData.logoRelativePath]. When a logo is present
  /// and within [maxWebLogoBytes], includes `logoBase64` + `logoExtension` so
  /// restore works across web ↔ native. Oversized logos export metadata only.
  Future<Map<String, dynamic>> exportForBackup(String userId) async {
    final data = await read(userId);
    final map = <String, dynamic>{
      'studioName': data.studioName,
      'accentColorArgb': data.accentColorArgb,
      'disclaimer': data.disclaimer,
      'hidePowerCoachBranding': data.hidePowerCoachBranding,
    };
    final bytes = await loadLogoBytes(userId);
    if (bytes == null || bytes.isEmpty) return map;
    if (bytes.length > maxWebLogoBytes) return map;

    final prefs = await SharedPreferences.getInstance();
    final extFromPrefs = prefs.getString(_logoExtKey(userId));
    final ext = _normalizeExtension(
      (extFromPrefs != null && extFromPrefs.isNotEmpty)
          ? extFromPrefs
          : _extensionFromRelativePath(data.logoRelativePath) ?? 'png',
    );
    map['logoBase64'] = base64Encode(bytes);
    map['logoExtension'] = ext;
    return map;
  }

  /// Restores brand metadata (+ optional logo) from a backup `pdfBrand` map.
  ///
  /// Missing/empty `logoBase64` clears any device-local logo so replace/merge
  /// match the backup. Invalid or oversized logo bytes keep metadata and skip
  /// the logo (no throw).
  Future<void> applyFromBackupMap(
    String userId,
    Map<String, dynamic> map,
  ) async {
    if (userId.isEmpty) return;

    final accentRaw = map['accentColorArgb'];
    int? accent;
    if (accentRaw is int) {
      accent = accentRaw;
    } else if (accentRaw is num) {
      accent = accentRaw.toInt();
    }

    await write(
      userId,
      PdfBrandData(
        studioName: map['studioName']?.toString() ?? '',
        accentColorArgb: accent,
        disclaimer: map['disclaimer']?.toString() ?? '',
        hidePowerCoachBranding: map['hidePowerCoachBranding'] == true,
      ),
    );

    final logoB64 = map['logoBase64']?.toString();
    if (logoB64 == null || logoB64.isEmpty) {
      await clearLogo(userId);
      return;
    }

    late final Uint8List bytes;
    try {
      bytes = base64Decode(logoB64);
    } catch (_) {
      await clearLogo(userId);
      return;
    }
    if (bytes.isEmpty) {
      await clearLogo(userId);
      return;
    }

    final ext = _normalizeExtension(map['logoExtension']?.toString() ?? 'png');
    try {
      await saveLogo(userId, bytes, extension: ext);
    } on PdfBrandLogoTooLargeException {
      // Keep metadata; leave logo cleared rather than failing the whole restore.
      await clearLogo(userId);
    }
  }

  static String? _extensionFromRelativePath(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return null;
    final dot = relativePath.lastIndexOf('.');
    if (dot < 0 || dot == relativePath.length - 1) return null;
    return relativePath.substring(dot + 1);
  }

  static String _normalizeExtension(String extension) {
    var ext = extension.trim().toLowerCase();
    if (ext.startsWith('.')) ext = ext.substring(1);
    if (ext == 'jpeg') return 'jpg';
    if (ext == 'jpg' || ext == 'png') return ext;
    return 'png';
  }
}
