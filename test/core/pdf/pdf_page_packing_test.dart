import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/pdf/pdf_page_packing.dart';

void main() {
  group('denseContentBudget', () {
    test('first page budget is tighter than later pages', () {
      final first = denseContentBudget(firstPage: true);
      final later = denseContentBudget(firstPage: false);
      expect(first, lessThan(later));
      expect(first, greaterThan(600));
      expect(later, lessThan(pdfA4HeightPoints));
    });
  });

  group('estimateDenseDayHeight', () {
    test('grows with row count and pads for many weeks', () {
      final short = estimateDenseDayHeight(rowCount: 3, weekCount: 2);
      final tall = estimateDenseDayHeight(rowCount: 12, weekCount: 2);
      final wide = estimateDenseDayHeight(rowCount: 3, weekCount: 4);
      expect(tall, greaterThan(short));
      expect(wide, greaterThan(short));
    });
  });

  group('packConsecutiveByHeight', () {
    test('three short days fit in one batch', () {
      final items = [120.0, 120.0, 120.0];
      final batches = packConsecutiveByHeight(
        items,
        (h) => h,
        pageBudget: 400,
      );
      expect(batches, hasLength(1));
      expect(batches.single, hasLength(3));
    });

    test('four short days with maxItemsPerBatch 3 split into two batches', () {
      final items = [100.0, 100.0, 100.0, 100.0];
      final batches = packConsecutiveByHeight(
        items,
        (h) => h,
        pageBudget: 400,
        maxItemsPerBatch: 3,
      );
      expect(batches, hasLength(2));
      expect(batches[0], hasLength(3));
      expect(batches[1], hasLength(1));
    });

    test('four short days with tight budget split by height', () {
      final items = [120.0, 120.0, 120.0, 120.0];
      final batches = packConsecutiveByHeight(
        items,
        (h) => h,
        pageBudget: 250,
        maxItemsPerBatch: 10,
      );
      expect(batches, hasLength(2));
      expect(batches[0], hasLength(2));
      expect(batches[1], hasLength(2));
    });

    test('tall day alone; short+tall+short become separate batches', () {
      final items = [80.0, 500.0, 80.0];
      final batches = packConsecutiveByHeight(
        items,
        (h) => h,
        pageBudget: 400,
      );
      expect(batches, [
        [80.0],
        [500.0],
        [80.0],
      ]);
    });

    test('item taller than budget flushes current batch then emits alone', () {
      final items = [100.0, 100.0, 900.0, 100.0];
      final batches = packConsecutiveByHeight(
        items,
        (h) => h,
        pageBudget: 400,
      );
      expect(batches, [
        [100.0, 100.0],
        [900.0],
        [100.0],
      ]);
    });
  });

  group('canAttachMobilityToFirstBatch', () {
    test('true when mobility + first batch fit first-page budget', () {
      expect(
        canAttachMobilityToFirstBatch(
          mobilityHeight: 80,
          firstBatchHeight: 200,
          firstPageBudget: 300,
        ),
        isTrue,
      );
    });

    test('false when sum exceeds budget', () {
      expect(
        canAttachMobilityToFirstBatch(
          mobilityHeight: 120,
          firstBatchHeight: 220,
          firstPageBudget: 300,
        ),
        isFalse,
      );
    });

    test('false when mobility or batch height is zero', () {
      expect(
        canAttachMobilityToFirstBatch(
          mobilityHeight: 0,
          firstBatchHeight: 200,
          firstPageBudget: 300,
        ),
        isFalse,
      );
      expect(
        canAttachMobilityToFirstBatch(
          mobilityHeight: 80,
          firstBatchHeight: 0,
          firstPageBudget: 300,
        ),
        isFalse,
      );
    });
  });

  group('estimateMobilityHeight', () {
    test('dense uses more columns so fewer rows for same sections', () {
      final dense = estimateMobilityHeight(
        sectionCount: 3,
        itemCount: 9,
        dense: true,
      );
      final canonical = estimateMobilityHeight(
        sectionCount: 3,
        itemCount: 9,
        dense: false,
      );
      expect(dense, lessThan(canonical));
    });
  });

  group('packConsecutiveByHeightWithFirstPageBudget', () {
    test('first batch uses tighter first-page budget', () {
      // Later budget (400) would pack three 120s; first (250) packs only two.
      final items = [120.0, 120.0, 120.0];
      final batches = packConsecutiveByHeightWithFirstPageBudget(
        items,
        (h) => h,
        firstPageBudget: 250,
        laterPageBudget: 400,
      );
      expect(batches, [
        [120.0, 120.0],
        [120.0],
      ]);
    });

    test('reserved mobility height shrinks first batch', () {
      final items = [100.0, 100.0, 100.0];
      final batches = packConsecutiveByHeightWithFirstPageBudget(
        items,
        (h) => h,
        firstPageBudget: 300,
        laterPageBudget: 400,
        reservedFirstPageHeight: 120,
      );
      // firstBudget becomes 180 → only one 100 fits.
      expect(batches.first, hasLength(1));
      expect(batches.expand((b) => b).length, 3);
    });

    test('oversized first item alone then later packs rest', () {
      final items = [500.0, 100.0, 100.0];
      final batches = packConsecutiveByHeightWithFirstPageBudget(
        items,
        (h) => h,
        firstPageBudget: 250,
        laterPageBudget: 400,
      );
      expect(batches, [
        [500.0],
        [100.0, 100.0],
      ]);
    });
  });
}
