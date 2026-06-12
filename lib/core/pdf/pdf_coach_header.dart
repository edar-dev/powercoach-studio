import '../../features/customers/data/models/customer.dart';
import '../storage/local_user_profile_store.dart';
import 'pdf_export_labels.dart';

/// Three-column header band shown at the top of workout PDFs (Stitch prototype).
class PdfCoachHeaderInfo {
  const PdfCoachHeaderInfo({
    required this.leftLine,
    this.centerLine,
    this.rightLine,
  });

  final String leftLine;
  final String? centerLine;
  final String? rightLine;

  bool get hasContent =>
      leftLine.trim().isNotEmpty ||
      (centerLine?.trim().isNotEmpty ?? false) ||
      (rightLine?.trim().isNotEmpty ?? false);
}

PdfCoachHeaderInfo buildPdfCoachHeader({
  required PdfExportLabels labels,
  Customer? customer,
  LocalUserProfileData? profile,
  String? authEmail,
}) {
  final prof = profile ?? const LocalUserProfileData();
  final customHeader = customer != null &&
      customer.useCustomPdfHeader &&
      (customer.pdfHeader?.trim().isNotEmpty ?? false);

  final left = customHeader
      ? customer.pdfHeader!.trim()
      : (prof.bio.trim().isNotEmpty ? prof.bio.trim() : labels.brandName);

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

  return PdfCoachHeaderInfo(
    leftLine: left,
    centerLine: center,
    rightLine: right,
  );
}
