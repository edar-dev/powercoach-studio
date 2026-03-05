# Stitch prototype – 8 screens (Project Landing Page)

**Project:** Landing Page  
**Project ID:** `13531110169329089006`

Estratti da Stitch: layout, colori HEX, typography (fontSize, weight), spacing, elevation/shadows.  
Implementazione Flutter: `lib/screens/`, `lib/widgets/`, Material 3 (`ThemeData(useMaterial3: true)`), solo Material widgets.

---

## Lista schermi da prototipo

| # | Screen name              | Stitch screen ID        | Flutter file |
|---|--------------------------|-------------------------|--------------|
| 1 | Simplified Startup Landing Page | `0b414c91bc8d406ea47ac2570d7b51df` | `lib/features/landing/presentation/screens/landing_screen.dart` |
| 2 | Personal Info Settings   | `0f594d4c05da4c8aa79172ab31ce8790` | `lib/features/settings/presentation/screens/personal_info_screen.dart` |
| 3 | Subscription Settings    | `1224a49f9c5849fcb205e965ebc0b9a4` | `lib/features/settings/presentation/screens/subscription_screen.dart` |
| 4 | Forgot Password          | `3563377ad3864dfca42385fcd5ea0840` | `lib/features/auth/.../forgot_password_screen.dart` |
| 5 | Login Page               | `3e212f412ed849a9b6bcfc0772cf15fd` | `lib/features/auth/presentation/screens/login_screen.dart` |
| 6 | Updated Coach Profile    | `5863bd21319d467b828ad322f8670305` | `lib/features/auth/presentation/screens/profile_screen.dart` |
| 7 | Simplified Registration Page | `76b61a47b6324d31bfd4957cd921aaee` | `lib/features/auth/presentation/screens/registration_screen.dart` |
| 8 | Simplified App Settings  | `8ab8a84172594c1c9911b5762e2a7257` | `lib/features/settings/presentation/screens/settings_screen.dart` |
| 9 | Empty Customer List Page  | `3d09f0f5b58f4867990e02be11ffc7d2` | `lib/features/customers/.../customer_list_screen.dart` (empty state) |
| 10 | Customer Creation Page    | `534f6e3664244ba59196220f2909eb46` | `lib/features/customers/.../customer_creation_screen.dart` |
| 11 | Customer Detail Page      | `7a7f3b47bfa1435381554959ca9b72e7` | `lib/features/customers/.../customer_detail_screen.dart` |
| 12 | Customer List (Populated) | `92b1ea1864184682b142aa8ffea211f8` | `lib/features/customers/.../customer_list_screen.dart` (list + search + chips) |
| 13 | Workout Builder - Enhanced Mobility Controls | `694ace9b83514965989f12ac2a3d54fa` | `lib/features/workouts/.../workout_builder_mobility_screen.dart` (variant: mobility) |
| 14 | Workout Builder - Multi-set with Large Fields | `9ffa631fd06348a7825d21888f1f20dd` | `lib/features/workouts/.../workout_builder_mobility_screen.dart` (variant: multiset) |
| 15 | Workout Builder - Super Set Linking | `e63b1ef6de2747319b80346360090548` | `lib/features/workouts/.../workout_builder_mobility_screen.dart` (variant: superset) |

---

## Design tokens (pixel-perfect)

- **Colori HEX (Stitch):** vedi `lib/theme/stitch_m3_theme.dart`: primary/accent `#0D59F2`, background-light/bgSecondary `#F5F6F8`, bg `#FFFFFF`, textPrimary `#1F2937`, textMuted `#6B7280`, border `#E5E7EB`, accentLight `#E8EEFE`, logo gradient `#3B82F6` → `#9333EA`, danger/success/warning.
- **Spacing:** padding 16, 24; gap 16, 24, 32; `formFieldSpacing = 20`; `radiusMd = 8`, `radiusLg = 12`, `radiusXl = 16`.
- **Typography:** displayMedium 36px w700, headlineMedium 24 w700, titleLarge 18 w600, body 16/14, label 14 w500.
- **Cards:** bg white, rounded-xl (12), border gray-200, shadow blur 10, offset (0, 2), alpha 0.05.
- **Auth card:** `authCardMaxWidth = 448`, `authHeaderPadding`, `authCardPadding`, `inputHeight = 48`.
- **Input:** `inputDecorationTheme` con radiusMd (8), contentPadding 16×14.
- **Responsive:** `MediaQuery.sizeOf(context).width < 600` → mobile; padding 24 mobile, 32 desktop.
- **Tema unico:** tutte le schermate usano `StitchM3Theme` (non più `AppTheme`) per corrispondenza pixel-perfect con il prototipo Stitch.

---

## Download asset Stitch

```powershell
# Esempio: landing
$env:STITCH_SIMPLIFIED_LANDING_SCREENSHOT_URL = "<url>"
$env:STITCH_SIMPLIFIED_LANDING_HTML_URL = "<url>"
.\scripts\download-stitch-assets.ps1
```

Oppure `curl -L -o design/stitch-assets/<nome>.png "<url>"`.
