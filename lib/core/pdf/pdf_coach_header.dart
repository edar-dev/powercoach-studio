import 'dart:typed_data';

import '../../features/customers/data/models/customer.dart';
import '../storage/local_user_profile_store.dart';
import 'pdf_brand_store.dart';
import 'pdf_export_labels.dart';

/// Three-column header band shown at the top of workout PDFs (Stitch prototype).
class PdfCoachHeaderInfo {
  const PdfCoachHeaderInfo({
    required this.leftLine,
    this.centerLine,
    this.rightLine,
    this.logoBytes,
    this.accentColorArgb,
    this.disclaimer,
    this.hideProductBranding = false,
  });

  final String leftLine;
  final String? centerLine;
  final String? rightLine;
  final Uint8List? logoBytes;
  final int? accentColorArgb;
  final String? disclaimer;
  final bool hideProductBranding;

  bool get hasLogo => logoBytes != null && logoBytes!.isNotEmpty;

  bool get hasContent =>
      leftLine.trim().isNotEmpty ||
      (centerLine?.trim().isNotEmpty ?? false) ||
      (rightLine?.trim().isNotEmpty ?? false) ||
      hasLogo;
}

PdfCoachHeaderInfo buildPdfCoachHeader({
  required PdfExportLabels labels,
  Customer? customer,
  LocalUserProfileData? profile,
  String? authEmail,
  PdfBrandData? brand,
  Uint8List? logoBytes,
}) {
  final prof = profile ?? const LocalUserProfileData();
  final brandData = brand ?? const PdfBrandData();
  final customHeader = customer != null &&
      customer.useCustomPdfHeader &&
      (customer.pdfHeader?.trim().isNotEmpty ?? false);

  final String left;
  if (customHeader) {
    left = customer.pdfHeader!.trim();
  } else {
    final studio = brandData.studioName.trim();
    if (studio.isNotEmpty) {
      left = studio;
    } else if (prof.bio.trim().isNotEmpty) {
      left = prof.bio.trim();
    } else if (!brandData.hidePowerCoachBranding) {
      left = labels.brandName;
    } else {
      left = '';
    }
  }

  String? center;
  final coachName = prof.displayName.trim();
  if (coachName.isNotEmpty) {
    center = '${labels.coachPrefix} $coachName';
  }

  String? right;
  if (prof.website.trim().isNotEmpty) {
    right = prof.website.trim();
  } else if (prof.phone.trim().isNotEmpty) {
    right = prof.phone.trim();
  } else {
    final email = authEmail?.trim() ?? '';
    if (email.isNotEmpty) right = email;
  }

  final disclaimer = brandData.disclaimer.trim();

  return PdfCoachHeaderInfo(
    leftLine: left,
    centerLine: center,
    rightLine: right,
    logoBytes: logoBytes,
    accentColorArgb: brandData.accentColorArgb,
    disclaimer: disclaimer.isEmpty ? null : disclaimer,
    hideProductBranding: brandData.hidePowerCoachBranding,
  );
}
