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

/// Like [packConsecutiveByHeight], but the first batch uses [firstPageBudget]
/// (tighter, coach header + legend) and later batches use [laterPageBudget].
///
/// When [reservedFirstPageHeight] is set (e.g. short mobility we hope to
/// attach), the first-batch budget is reduced so mobility + days fit page 1.
List<List<T>> packConsecutiveByHeightWithFirstPageBudget<T>(
  List<T> items,
  double Function(T) heightOf, {
  required double firstPageBudget,
  required double laterPageBudget,
  double reservedFirstPageHeight = 0,
  int maxItemsPerBatch = 3,
}) {
  if (items.isEmpty) return const [];

  var firstBudget = firstPageBudget;
  if (reservedFirstPageHeight > 0 &&
      reservedFirstPageHeight < firstPageBudget) {
    final remaining = firstPageBudget - reservedFirstPageHeight;
    // Only reserve when there is still room for at least one short day.
    if (remaining >= 80) {
      firstBudget = remaining;
    }
  }

  final firstBatch = <T>[];
  var used = 0.0;
  var index = 0;

  for (; index < items.length; index++) {
    final item = items[index];
    final h = heightOf(item);
    if (h > firstBudget) {
      if (firstBatch.isEmpty) {
        // Oversized for page 1: emit alone, pack the rest with later budget.
        return [
          [item],
          ...packConsecutiveByHeight(
            items.sublist(index + 1),
            heightOf,
            pageBudget: laterPageBudget,
            maxItemsPerBatch: maxItemsPerBatch,
          ),
        ];
      }
      break;
    }
    final wouldExceedBudget = firstBatch.isNotEmpty && used + h > firstBudget;
    final wouldExceedCap =
        firstBatch.isNotEmpty && firstBatch.length >= maxItemsPerBatch;
    if (firstBatch.isEmpty || (!wouldExceedBudget && !wouldExceedCap)) {
      firstBatch.add(item);
      used += h;
    } else {
      break;
    }
  }

  return [
    firstBatch,
    ...packConsecutiveByHeight(
      items.sublist(index),
      heightOf,
      pageBudget: laterPageBudget,
      maxItemsPerBatch: maxItemsPerBatch,
    ),
  ];
}
