import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/billing/billing_promo.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/features/settings/presentation/widgets/subscription/subscription_promo_redeem_card.dart';
import 'package:powercoach_studio/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) {
    return MaterialApp(
      theme: StitchM3Theme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  testWidgets('redeems code and calls onRedeemed', (tester) async {
    var redeemed = false;
    String? submittedCode;

    await tester.pumpWidget(
      wrap(
        SubscriptionPromoRedeemCard(
          hasPendingCouponRequest: false,
          onRedeemed: () async {
            redeemed = true;
          },
          onRedeemCode: (code) async {
            submittedCode = code;
            return const RedeemPromoResult();
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'POWERCOACH-BETA');
    await tester.tap(find.text('Redeem'));
    await tester.pumpAndSettle();

    expect(submittedCode, 'POWERCOACH-BETA');
    expect(redeemed, isTrue);
    expect(find.text('Pro unlocked with your promo code.'), findsOneWidget);
  });

  testWidgets('shows validation when code is empty', (tester) async {
    await tester.pumpWidget(
      wrap(
        SubscriptionPromoRedeemCard(
          hasPendingCouponRequest: false,
          onRedeemed: () async {},
          onRedeemCode: (_) async => const RedeemPromoResult(),
        ),
      ),
    );

    await tester.tap(find.text('Redeem'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a promo code.'), findsWidgets);
  });

  testWidgets('maps invalid code error', (tester) async {
    await tester.pumpWidget(
      wrap(
        SubscriptionPromoRedeemCard(
          hasPendingCouponRequest: false,
          onRedeemed: () async {},
          onRedeemCode: (_) async {
            throw BillingPromoException('Invalid or inactive promo code');
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'BAD-CODE');
    await tester.tap(find.text('Redeem'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid or inactive promo code.'), findsWidgets);
  });

  testWidgets('request invite shows pending copy when already pending',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        const SubscriptionPromoRedeemCard(
          hasPendingCouponRequest: true,
          onRedeemed: _noop,
        ),
      ),
    );

    expect(
      find.text("Request already sent — we'll email you a code."),
      findsOneWidget,
    );
    expect(find.text('Request invite code'), findsNothing);
  });

  testWidgets('request invite submits and shows success', (tester) async {
    var refreshed = false;
    var requested = false;

    await tester.pumpWidget(
      wrap(
        SubscriptionPromoRedeemCard(
          hasPendingCouponRequest: false,
          onRedeemed: () async {
            refreshed = true;
          },
          onRequestCoupon: ({String? message}) async {
            requested = true;
            return const CouponRequestResult();
          },
        ),
      ),
    );

    await tester.tap(find.text('Request invite code'));
    await tester.pumpAndSettle();

    expect(requested, isTrue);
    expect(refreshed, isTrue);
    expect(
      find.text("Request sent. We'll email you a code."),
      findsOneWidget,
    );
  });
}

Future<void> _noop() async {}
