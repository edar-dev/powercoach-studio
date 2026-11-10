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
/// Prefer slight overestimate so packing stays conservative. Tall days that
/// still exceed a page are emitted with Table spanning (see export usecase).
///
/// Note: wrapped 4-week prescription cells routinely render far taller than
/// this estimate (production: ~820pt for content this helper may call ~300).
/// Never use the estimate alone to keep a Table inside [Inseparable].
double estimateDenseDayHeight({
  required int rowCount,
  required int weekCount,
}) {
  const title = 18.0;
  const headerRow = 14.0;
  // Slightly generous vs typical rendered row height so packing errs early.
  const row = 18.0;
  const afterGap = 8.0;
  var height = title + headerRow + rowCount * row + afterGap;
  // Wider week columns can wrap labels; pad more for 4+ weeks.
  if (weekCount >= 4) {
    height += 12.0;
  }
  return height;
}

/// Max fraction of [pageBudget] at which a dense day may stay inseparable
/// (title+table). Default `0` = always emit Table as a MultiPage child.
///
/// Estimates under-count wrapped cells; any non-zero factor must stay far
/// below real rendered height (POWERCOACH-STUDIO-F / G: ~820 > ~806).
const double denseDayInseparableSafetyFactor = 0.0;

/// Whether title+table may share one non-spanning Inseparable.
///
/// Prefer spanning. Only returns true when [estimatedHeight] is safely under
/// [pageBudget] * [safetyFactor]. With the default factor of `0`, always
/// returns false so dense day Tables never nest in Inseparable/Column.
bool denseDayCanKeepInseparable({
  required double estimatedHeight,
  required double pageBudget,
  double safetyFactor = denseDayInseparableSafetyFactor,
}) {
  if (safetyFactor <= 0 || estimatedHeight <= 0 || pageBudget <= 0) {
    return false;
  }
  return estimatedHeight <= pageBudget * safetyFactor;
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
///   that item alone (caller may then use Table spanning for overflow).
/// - Otherwise pack while `used + h <= pageBudget`.
/// - Cap batch size with [maxItemsPerBatch] (default 3).
/// - Never uses canSpan; short batches wrap Inseparable, tall days span via Table.
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
