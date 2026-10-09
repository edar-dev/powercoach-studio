import 'pdf_document_theme.dart';

/// A4 height in PDF points (PdfPageFormat.a4.height ≈ 841.89).
const double pdfA4HeightPoints = 841.89;

/// Usable content height for dense MultiPage layout after margins/header/footer.
///
/// Prefer slight overestimate of reserved chrome so batches stay conservative.
double denseContentBudget({required bool firstPage}) {
  const margin = PdfDocumentTheme.densePageMargin * 2;
  final headerReserve = firstPage ? 110.0 : 36.0;
  const footerReserve = 28.0;
  return pdfA4HeightPoints - margin - headerReserve - footerReserve;
}

/// Estimated height of one dense day block (title + table + trailing gap).
///
/// Prefer slight overestimate so packing never under-fills a page into overflow.
double estimateDenseDayHeight({
  required int rowCount,
  required int weekCount,
}) {
  const title = 18.0;
  const headerRow = 14.0;
  const row = 16.0;
  const afterGap = 8.0;
  var height = title + headerRow + rowCount * row + afterGap;
  // Wider week columns can wrap labels; pad a little for 4+ weeks.
  if (weekCount >= 4) {
    height += 8.0;
  }
  return height;
}

/// Estimated height of the mobility section block (title + grid + trailing gap).
double estimateMobilityHeight({
  required int sectionCount,
  required int itemCount,
  required bool dense,
}) {
  if (sectionCount <= 0) return 0;
  final columns = dense ? 3 : 2;
  final rows = (sectionCount / columns).ceil();
  final avgItems = itemCount / sectionCount;
  return 22 + rows * (28 + avgItems * 12) + 8;
}

/// Whether short mobility can share the first page with the first day batch.
bool canAttachMobilityToFirstBatch({
  required double mobilityHeight,
  required double firstBatchHeight,
  required double firstPageBudget,
}) {
  if (mobilityHeight <= 0 || firstBatchHeight <= 0) return false;
  return mobilityHeight + firstBatchHeight <= firstPageBudget;
}

/// Greedy pack of consecutive items by estimated height.
///
/// Rules:
/// - Never split an item across batches.
/// - If an item is taller than [pageBudget], flush the current batch and emit
///   that item alone (may still overflow a real page — existing tradeoff).
/// - Otherwise pack while `used + h <= pageBudget`.
/// - Cap batch size with [maxItemsPerBatch] (default 3).
/// - Never uses canSpan (caller wraps batches in Inseparable without canSpan).
List<List<T>> packConsecutiveByHeight<T>(
  List<T> items,
  double Function(T) heightOf, {
  required double pageBudget,
  int maxItemsPerBatch = 3,
}) {
  final pages = <List<T>>[];
  var batch = <T>[];
  var used = 0.0;

  void flush() {
    if (batch.isEmpty) return;
    pages.add(batch);
    batch = <T>[];
    used = 0;
  }

  for (final item in items) {
    final h = heightOf(item);
    if (h > pageBudget) {
      flush();
      pages.add([item]);
      continue;
    }
    final wouldExceedBudget = batch.isNotEmpty && used + h > pageBudget;
    final wouldExceedCap =
        batch.isNotEmpty && batch.length >= maxItemsPerBatch;
    if (batch.isEmpty || (!wouldExceedBudget && !wouldExceedCap)) {
      batch.add(item);
      used += h;
    } else {
      flush();
      batch.add(item);
      used = h;
    }
  }
  flush();
  return pages;
}
