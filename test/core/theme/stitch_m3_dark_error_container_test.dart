import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:powercoach_studio/core/theme/stitch_m3_theme.dart';
import 'package:powercoach_studio/core/theme/stitch_mobile_colors.dart';

void main() {
  test('dark ColorScheme sets Stitch errorContainer / onErrorContainer', () {
    final scheme = StitchM3Theme.dark.colorScheme;
    expect(scheme.errorContainer, StitchMobileColors.errorContainer);
    expect(scheme.onErrorContainer, StitchMobileColors.onErrorContainer);
    expect(scheme.errorContainer, const Color(0xFF93000A));
    expect(scheme.onErrorContainer, const Color(0xFFFFDAD6));
  });
}
