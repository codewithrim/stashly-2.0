import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stashly/core/theme.dart';
import 'package:stashly/data/models/item.dart';

double _luminance(Color color) {
  double channel(double c) {
    return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channel(color.r);
  final g = channel(color.g);
  final b = channel(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrastRatio(Color c1, Color c2) {
  final l1 = _luminance(c1);
  final l2 = _luminance(c2);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('AppTheme & StashlyColors Verification', () {
    test('Light theme has Stashly extensions attached', () {
      final theme = AppTheme.lightTheme;
      final colors = theme.extension<StashlyColors>();
      final typography = theme.extension<StashlyTypography>();

      expect(colors, isNotNull);
      expect(typography, isNotNull);
      expect(theme.brightness, Brightness.light);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.scaffoldBackgroundColor, colors!.surfaceBackground);
    });

    test('Dark theme has Stashly extensions attached', () {
      final theme = AppTheme.darkTheme;
      final colors = theme.extension<StashlyColors>();
      final typography = theme.extension<StashlyTypography>();

      expect(colors, isNotNull);
      expect(typography, isNotNull);
      expect(theme.brightness, Brightness.dark);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.scaffoldBackgroundColor, colors!.surfaceBackground);
    });

    test('Light theme contrast ratios pass WCAG AA (>= 4.5:1)', () {
      const c = StashlyColors.light;

      // Text on White Paper Card
      final textOnCard = _contrastRatio(c.textPrimary, c.surfaceCard);
      expect(textOnCard, greaterThanOrEqualTo(14.0));

      final secondaryOnCard = _contrastRatio(c.textSecondary, c.surfaceCard);
      expect(secondaryOnCard, greaterThanOrEqualTo(7.0));

      final tertiaryOnCard = _contrastRatio(c.textTertiary, c.surfaceCard);
      expect(tertiaryOnCard, greaterThanOrEqualTo(4.5));

      // Text on Warm Linen Canvas
      final textOnCanvas = _contrastRatio(c.textPrimary, c.surfaceBackground);
      expect(textOnCanvas, greaterThanOrEqualTo(14.0));

      final secondaryOnCanvas =
          _contrastRatio(c.textSecondary, c.surfaceBackground);
      expect(secondaryOnCanvas, greaterThanOrEqualTo(7.0));

      final tertiaryOnCanvas =
          _contrastRatio(c.textTertiary, c.surfaceBackground);
      expect(tertiaryOnCanvas, greaterThanOrEqualTo(4.5));

      // Primary Button Text (White on AccentPrimary)
      final whiteOnPrimary = _contrastRatio(Colors.white, c.accentPrimary);
      expect(whiteOnPrimary, greaterThanOrEqualTo(4.5));

      // Type Badge Pairings
      final noteBadge = _contrastRatio(c.badgeNoteFg, c.badgeNoteBg);
      expect(noteBadge, greaterThanOrEqualTo(4.5));

      final linkBadge = _contrastRatio(c.badgeLinkFg, c.badgeLinkBg);
      expect(linkBadge, greaterThanOrEqualTo(4.5));

      final imageBadge = _contrastRatio(c.badgeImageFg, c.badgeImageBg);
      expect(imageBadge, greaterThanOrEqualTo(4.5));

      // Synced Badge Pairing (Light mode)
      final syncBadge =
          _contrastRatio(c.onStatusSuccessContainer, c.statusSuccessContainer);
      expect(syncBadge, greaterThanOrEqualTo(4.5));
    });

    test('Dark theme contrast ratios pass WCAG AA (>= 4.5:1)', () {
      const c = StashlyColors.dark;

      // Restrained forest green (#24392F) and soft mint text (#A3D9B1)
      expect(c.statusSuccessContainer, const Color(0xFF24392F));
      expect(c.onStatusSuccessContainer, const Color(0xFFA3D9B1));

      final syncBadge =
          _contrastRatio(c.onStatusSuccessContainer, c.statusSuccessContainer);
      expect(syncBadge, greaterThanOrEqualTo(7.0));

      // Text on Elevated Navy Card
      final textOnCard = _contrastRatio(c.textPrimary, c.surfaceCard);
      expect(textOnCard, greaterThanOrEqualTo(14.0));

      final secondaryOnCard = _contrastRatio(c.textSecondary, c.surfaceCard);
      expect(secondaryOnCard, greaterThanOrEqualTo(6.5));

      final tertiaryOnCard = _contrastRatio(c.textTertiary, c.surfaceCard);
      expect(tertiaryOnCard, greaterThanOrEqualTo(4.5));

      // Text on Deep Canvas (#131A27)
      final textOnCanvas = _contrastRatio(c.textPrimary, c.surfaceBackground);
      expect(textOnCanvas, greaterThanOrEqualTo(15.0));

      final secondaryOnCanvas =
          _contrastRatio(c.textSecondary, c.surfaceBackground);
      expect(secondaryOnCanvas, greaterThanOrEqualTo(7.0));

      final tertiaryOnCanvas =
          _contrastRatio(c.textTertiary, c.surfaceBackground);
      expect(tertiaryOnCanvas, greaterThanOrEqualTo(4.5));

      // Deep Navy button text on Honey Yellow Accent (#172B4D on #F2C66D)
      final navyOnHoney =
          _contrastRatio(const Color(0xFF172B4D), c.accentHoney);
      expect(navyOnHoney, greaterThanOrEqualTo(7.0));

      // Crisp text on Dark Navy Interactive surface (#F1F3F7 on #263C60)
      final textOnInteractive =
          _contrastRatio(c.textPrimary, c.accentInteractive);
      expect(textOnInteractive, greaterThanOrEqualTo(7.0));

      // Type Badge Pairings
      final noteBadge = _contrastRatio(c.badgeNoteFg, c.badgeNoteBg);
      expect(noteBadge, greaterThanOrEqualTo(4.5));

      final linkBadge = _contrastRatio(c.badgeLinkFg, c.badgeLinkBg);
      expect(linkBadge, greaterThanOrEqualTo(4.5));

      final imageBadge = _contrastRatio(c.badgeImageFg, c.badgeImageBg);
      expect(imageBadge, greaterThanOrEqualTo(4.5));
    });

    test(
        'AppTheme helper methods return corresponding tokens for item types and sync badges',
        () {
      const c = StashlyColors.light;

      expect(AppTheme.typeColor(ItemType.note, c), c.accentNote);
      expect(AppTheme.typeColor(ItemType.link, c), c.accentLink);
      expect(AppTheme.typeColor(ItemType.image, c), c.accentImage);

      final syncedLight = AppTheme.syncBadgeColors(true, c);
      expect(syncedLight.background, c.statusSuccessContainer);
      expect(syncedLight.foreground, c.onStatusSuccessContainer);

      final offlineLight = AppTheme.syncBadgeColors(false, c);
      expect(offlineLight.background, c.statusWarningContainer);
      expect(offlineLight.foreground, c.onStatusWarningContainer);

      const d = StashlyColors.dark;
      final syncedDark = AppTheme.syncBadgeColors(true, d);
      expect(syncedDark.background, const Color(0xFF24392F));
      expect(syncedDark.foreground, const Color(0xFFA3D9B1));

      final noteBadge = AppTheme.typeBadgeColors(ItemType.note, c);
      expect(noteBadge.background, c.badgeNoteBg);
      expect(noteBadge.foreground, c.badgeNoteFg);

      final linkBadge = AppTheme.typeBadgeColors(ItemType.link, c);
      expect(linkBadge.background, c.badgeLinkBg);
      expect(linkBadge.foreground, c.badgeLinkFg);

      final imageBadge = AppTheme.typeBadgeColors(ItemType.image, c);
      expect(imageBadge.background, c.badgeImageBg);
      expect(imageBadge.foreground, c.badgeImageFg);
    });
  });
}
