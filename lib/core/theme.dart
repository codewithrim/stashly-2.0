import 'package:flutter/material.dart';
import '../data/models/item.dart';

/// Semantic color tokens for Stashly, validated against WCAG AA (>= 4.5:1 contrast).
@immutable
class StashlyColors extends ThemeExtension<StashlyColors> {
  final Color surfaceBackground;
  final Color surfaceCard;
  final Color surfaceSubtle;
  final Color surfaceBorder;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  final Color accentPrimary;
  final Color accentInteractive;
  final Color accentHoney;
  final Color accentNote;
  final Color accentLink;
  final Color accentImage;

  final Color badgeNoteBg;
  final Color badgeNoteFg;
  final Color badgeLinkBg;
  final Color badgeLinkFg;
  final Color badgeImageBg;
  final Color badgeImageFg;

  final Color statusSuccess;
  final Color statusSuccessContainer;
  final Color onStatusSuccessContainer;
  final Color statusWarning;
  final Color statusWarningContainer;
  final Color onStatusWarningContainer;
  final Color statusError;

  const StashlyColors({
    required this.surfaceBackground,
    required this.surfaceCard,
    required this.surfaceSubtle,
    required this.surfaceBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accentPrimary,
    required this.accentInteractive,
    required this.accentHoney,
    required this.accentNote,
    required this.accentLink,
    required this.accentImage,
    required this.badgeNoteBg,
    required this.badgeNoteFg,
    required this.badgeLinkBg,
    required this.badgeLinkFg,
    required this.badgeImageBg,
    required this.badgeImageFg,
    required this.statusSuccess,
    required this.statusSuccessContainer,
    required this.onStatusSuccessContainer,
    required this.statusWarning,
    required this.statusWarningContainer,
    required this.onStatusWarningContainer,
    required this.statusError,
  });

  /// Light theme palette:
  /// Deep navy blue (#172B4D) anchor, warm minimal background (#F8F7F4), honey yellow (#F2C66D) restrained accent.
  static const light = StashlyColors(
    surfaceBackground: Color(0xFFF8F7F4),
    surfaceCard: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFEFECE6),
    surfaceBorder: Color(0xFFE2DFD8),
    textPrimary: Color(0xFF1F2128),
    textSecondary: Color(0xFF4B5363),
    textTertiary: Color(0xFF6B7280),
    accentPrimary: Color(0xFF172B4D),
    accentInteractive: Color(0xFF172B4D),
    accentHoney: Color(0xFFF2C66D),
    accentNote: Color(0xFF374151),
    accentLink: Color(0xFF0F766E),
    accentImage: Color(0xFFC2410C),
    badgeNoteBg: Color(0xFFF1F5F9),
    badgeNoteFg: Color(0xFF334155),
    badgeLinkBg: Color(0xFFE6F4F1),
    badgeLinkFg: Color(0xFF0F766E),
    badgeImageBg: Color(0xFFFBF1EB),
    badgeImageFg: Color(0xFFC2410C),
    statusSuccess: Color(0xFF15803D),
    statusSuccessContainer: Color(0xFFE8F5E9),
    onStatusSuccessContainer: Color(0xFF166534),
    statusWarning: Color(0xFFB45309),
    statusWarningContainer: Color(0xFFFEF3C7),
    onStatusWarningContainer: Color(0xFF92400E),
    statusError: Color(0xFFB91C1C),
  );

  /// Dark theme palette:
  /// Dark canvas (#131A27), navy interactive surfaces (#263C60), crisp text (#F1F3F7), honey yellow (#F2C66D) selective accent.
  static const dark = StashlyColors(
    surfaceBackground: Color(0xFF131A27),
    surfaceCard: Color(0xFF1A2332),
    surfaceSubtle: Color(0xFF263C60),
    surfaceBorder: Color(0xFF2B3A50),
    textPrimary: Color(0xFFF1F3F7),
    textSecondary: Color(0xFFB9C2D1),
    textTertiary: Color(0xFF8692A6),
    accentPrimary: Color(0xFF172B4D),
    accentInteractive: Color(0xFF263C60),
    accentHoney: Color(0xFFF2C66D),
    accentNote: Color(0xFFCBD5E1),
    accentLink: Color(0xFF2DD4BF),
    accentImage: Color(0xFFFB923C),
    badgeNoteBg: Color(0xFF1E293B),
    badgeNoteFg: Color(0xFFE2E8F0),
    badgeLinkBg: Color(0xFF113835),
    badgeLinkFg: Color(0xFF5EEAD4),
    badgeImageBg: Color(0xFF3F1B0B),
    badgeImageFg: Color(0xFFFDBA74),
    statusSuccess: Color(0xFF4ADE80),
    statusSuccessContainer: Color(0xFF24392F),
    onStatusSuccessContainer: Color(0xFFA3D9B1),
    statusWarning: Color(0xFFFBBF24),
    statusWarningContainer: Color(0xFF3D2E14),
    onStatusWarningContainer: Color(0xFFFDE68A),
    statusError: Color(0xFFF87171),
  );

  @override
  StashlyColors copyWith({
    Color? surfaceBackground,
    Color? surfaceCard,
    Color? surfaceSubtle,
    Color? surfaceBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? accentPrimary,
    Color? accentInteractive,
    Color? accentHoney,
    Color? accentNote,
    Color? accentLink,
    Color? accentImage,
    Color? badgeNoteBg,
    Color? badgeNoteFg,
    Color? badgeLinkBg,
    Color? badgeLinkFg,
    Color? badgeImageBg,
    Color? badgeImageFg,
    Color? statusSuccess,
    Color? statusSuccessContainer,
    Color? onStatusSuccessContainer,
    Color? statusWarning,
    Color? statusWarningContainer,
    Color? onStatusWarningContainer,
    Color? statusError,
  }) {
    return StashlyColors(
      surfaceBackground: surfaceBackground ?? this.surfaceBackground,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      surfaceBorder: surfaceBorder ?? this.surfaceBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      accentPrimary: accentPrimary ?? this.accentPrimary,
      accentInteractive: accentInteractive ?? this.accentInteractive,
      accentHoney: accentHoney ?? this.accentHoney,
      accentNote: accentNote ?? this.accentNote,
      accentLink: accentLink ?? this.accentLink,
      accentImage: accentImage ?? this.accentImage,
      badgeNoteBg: badgeNoteBg ?? this.badgeNoteBg,
      badgeNoteFg: badgeNoteFg ?? this.badgeNoteFg,
      badgeLinkBg: badgeLinkBg ?? this.badgeLinkBg,
      badgeLinkFg: badgeLinkFg ?? this.badgeLinkFg,
      badgeImageBg: badgeImageBg ?? this.badgeImageBg,
      badgeImageFg: badgeImageFg ?? this.badgeImageFg,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusSuccessContainer:
          statusSuccessContainer ?? this.statusSuccessContainer,
      onStatusSuccessContainer:
          onStatusSuccessContainer ?? this.onStatusSuccessContainer,
      statusWarning: statusWarning ?? this.statusWarning,
      statusWarningContainer:
          statusWarningContainer ?? this.statusWarningContainer,
      onStatusWarningContainer:
          onStatusWarningContainer ?? this.onStatusWarningContainer,
      statusError: statusError ?? this.statusError,
    );
  }

  @override
  StashlyColors lerp(ThemeExtension<StashlyColors>? other, double t) {
    if (other is! StashlyColors) return this;
    return StashlyColors(
      surfaceBackground:
          Color.lerp(surfaceBackground, other.surfaceBackground, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      surfaceBorder: Color.lerp(surfaceBorder, other.surfaceBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      accentPrimary: Color.lerp(accentPrimary, other.accentPrimary, t)!,
      accentInteractive:
          Color.lerp(accentInteractive, other.accentInteractive, t)!,
      accentHoney: Color.lerp(accentHoney, other.accentHoney, t)!,
      accentNote: Color.lerp(accentNote, other.accentNote, t)!,
      accentLink: Color.lerp(accentLink, other.accentLink, t)!,
      accentImage: Color.lerp(accentImage, other.accentImage, t)!,
      badgeNoteBg: Color.lerp(badgeNoteBg, other.badgeNoteBg, t)!,
      badgeNoteFg: Color.lerp(badgeNoteFg, other.badgeNoteFg, t)!,
      badgeLinkBg: Color.lerp(badgeLinkBg, other.badgeLinkBg, t)!,
      badgeLinkFg: Color.lerp(badgeLinkFg, other.badgeLinkFg, t)!,
      badgeImageBg: Color.lerp(badgeImageBg, other.badgeImageBg, t)!,
      badgeImageFg: Color.lerp(badgeImageFg, other.badgeImageFg, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusSuccessContainer:
          Color.lerp(statusSuccessContainer, other.statusSuccessContainer, t)!,
      onStatusSuccessContainer: Color.lerp(
          onStatusSuccessContainer, other.onStatusSuccessContainer, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusWarningContainer:
          Color.lerp(statusWarningContainer, other.statusWarningContainer, t)!,
      onStatusWarningContainer: Color.lerp(
          onStatusWarningContainer, other.onStatusWarningContainer, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
    );
  }
}

/// Specialized typography tokens for editorial headlines, comfortable reading, and monospace metadata.
@immutable
class StashlyTypography extends ThemeExtension<StashlyTypography> {
  final TextStyle editorialHeadline;
  final TextStyle readingBody;
  final TextStyle monoHost;
  final TextStyle metaText;
  final TextStyle tagText;

  const StashlyTypography({
    required this.editorialHeadline,
    required this.readingBody,
    required this.monoHost,
    required this.metaText,
    required this.tagText,
  });

  static const light = StashlyTypography(
    editorialHeadline: TextStyle(
      fontFamily: 'serif',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: -0.2,
      color: Color(0xFF1E2022),
    ),
    readingBody: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.6,
      letterSpacing: 0,
      color: Color(0xFF1E2022),
    ),
    monoHost: TextStyle(
      fontFamily: 'monospace',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: Color(0xFF0F766E),
    ),
    metaText: TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w400,
      height: 1.4,
      letterSpacing: 0.1,
      color: Color(0xFF646A72),
    ),
    tagText: TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: Color(0xFF4B5158),
    ),
  );

  static const dark = StashlyTypography(
    editorialHeadline: TextStyle(
      fontFamily: 'serif',
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: -0.2,
      color: Color(0xFFF1F3F5),
    ),
    readingBody: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.6,
      letterSpacing: 0,
      color: Color(0xFFF1F3F5),
    ),
    monoHost: TextStyle(
      fontFamily: 'monospace',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: Color(0xFF2DD4BF),
    ),
    metaText: TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w400,
      height: 1.4,
      letterSpacing: 0.1,
      color: Color(0xFF8B929E),
    ),
    tagText: TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: Color(0xFFA0A6AF),
    ),
  );

  @override
  StashlyTypography copyWith({
    TextStyle? editorialHeadline,
    TextStyle? readingBody,
    TextStyle? monoHost,
    TextStyle? metaText,
    TextStyle? tagText,
  }) {
    return StashlyTypography(
      editorialHeadline: editorialHeadline ?? this.editorialHeadline,
      readingBody: readingBody ?? this.readingBody,
      monoHost: monoHost ?? this.monoHost,
      metaText: metaText ?? this.metaText,
      tagText: tagText ?? this.tagText,
    );
  }

  @override
  StashlyTypography lerp(ThemeExtension<StashlyTypography>? other, double t) {
    if (other is! StashlyTypography) return this;
    return StashlyTypography(
      editorialHeadline:
          TextStyle.lerp(editorialHeadline, other.editorialHeadline, t)!,
      readingBody: TextStyle.lerp(readingBody, other.readingBody, t)!,
      monoHost: TextStyle.lerp(monoHost, other.monoHost, t)!,
      metaText: TextStyle.lerp(metaText, other.metaText, t)!,
      tagText: TextStyle.lerp(tagText, other.tagText, t)!,
    );
  }
}

/// Ergonomic accessor extension for Theme.of(context)
extension StashlyThemeContextExtension on BuildContext {
  StashlyColors get stashlyColors =>
      Theme.of(this).extension<StashlyColors>() ?? StashlyColors.light;

  StashlyTypography get stashlyTypography =>
      Theme.of(this).extension<StashlyTypography>() ?? StashlyTypography.light;
}

/// Central application theme configuration.
class AppTheme {
  // Legacy backward-compatible static constants
  static const Color primaryColor = Color(0xFF172B4D);
  static const Color primaryDark = Color(0xFF131A27);
  static const Color accentHoney = Color(0xFFF2C66D);
  static const Color secondaryColor = Color(0xFF0F766E);
  static const Color noteColor = Color(0xFF374151);
  static const Color linkColor = Color(0xFF0F766E);
  static const Color imageColor = Color(0xFFC2410C);

  /// Helper to get the semantic color for an item type.
  static Color typeColor(ItemType type, StashlyColors colors) {
    switch (type) {
      case ItemType.note:
        return colors.accentNote;
      case ItemType.link:
        return colors.accentLink;
      case ItemType.image:
        return colors.accentImage;
    }
  }

  /// Helper to get badge background and foreground colors for an item type.
  static ({Color background, Color foreground}) typeBadgeColors(
    ItemType type,
    StashlyColors colors,
  ) {
    switch (type) {
      case ItemType.note:
        return (background: colors.badgeNoteBg, foreground: colors.badgeNoteFg);
      case ItemType.link:
        return (background: colors.badgeLinkBg, foreground: colors.badgeLinkFg);
      case ItemType.image:
        return (
          background: colors.badgeImageBg,
          foreground: colors.badgeImageFg
        );
    }
  }

  /// Helper to get sync status badge colors.
  static ({Color background, Color foreground}) syncBadgeColors(
    bool isSynced,
    StashlyColors colors,
  ) {
    if (isSynced) {
      return (
        background: colors.statusSuccessContainer,
        foreground: colors.onStatusSuccessContainer,
      );
    } else {
      return (
        background: colors.statusWarningContainer,
        foreground: colors.onStatusWarningContainer,
      );
    }
  }

  /// Builds the Light ThemeData.
  static ThemeData get lightTheme {
    const c = StashlyColors.light;
    const t = StashlyTypography.light;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      extensions: const [c, t],
      scaffoldBackgroundColor: c.surfaceBackground,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: c.accentPrimary,
        onPrimary: const Color(0xFFFFFFFF),
        secondary: c.accentLink,
        onSecondary: const Color(0xFFFFFFFF),
        tertiary: c.accentHoney,
        onTertiary: const Color(0xFF172B4D),
        surface: c.surfaceCard,
        onSurface: c.textPrimary,
        surfaceContainerLowest: c.surfaceBackground,
        surfaceContainer: c.surfaceSubtle,
        surfaceContainerHighest: c.surfaceSubtle,
        onSurfaceVariant: c.textSecondary,
        outline: c.surfaceBorder,
        outlineVariant: c.surfaceBorder,
        error: c.statusError,
        onError: const Color(0xFFFFFFFF),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: c.surfaceBackground,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: c.textPrimary, size: 22),
        actionsIconTheme: IconThemeData(color: c.textSecondary, size: 22),
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.surfaceCard,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.surfaceBorder, width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceCard,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: TextStyle(
          color: c.textTertiary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: c.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.surfaceBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.surfaceBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.accentPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.statusError, width: 1.0),
        ),
      ),
      chipTheme: ChipThemeData(
        elevation: 0,
        pressElevation: 0,
        backgroundColor: c.surfaceCard,
        selectedColor: c.surfaceSubtle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: c.surfaceBorder, width: 1.0),
        ),
        labelStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          color: c.accentPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accentHoney,
        foregroundColor: const Color(0xFF172B4D),
        elevation: 2,
        focusElevation: 3,
        hoverElevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.surfaceBorder,
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: c.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: c.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: c.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.15,
          height: 1.35,
          color: c.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: c.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.45,
          color: c.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: c.textTertiary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: c.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: c.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: c.textTertiary,
        ),
      ),
    );
  }

  /// Builds the Dark ThemeData.
  static ThemeData get darkTheme {
    const c = StashlyColors.dark;
    const t = StashlyTypography.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      extensions: const [c, t],
      scaffoldBackgroundColor: c.surfaceBackground,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: c.accentPrimary,
        onPrimary: const Color(0xFFF1F3F7),
        secondary: c.accentLink,
        onSecondary: const Color(0xFF131A27),
        tertiary: c.accentHoney,
        onTertiary: const Color(0xFF172B4D),
        surface: c.surfaceCard,
        onSurface: c.textPrimary,
        surfaceContainerLowest: c.surfaceBackground,
        surfaceContainer: c.surfaceSubtle,
        surfaceContainerHighest: c.surfaceSubtle,
        onSurfaceVariant: c.textSecondary,
        outline: c.surfaceBorder,
        outlineVariant: c.surfaceBorder,
        error: c.statusError,
        onError: const Color(0xFF131A27),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: c.surfaceBackground,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: c.textPrimary, size: 22),
        actionsIconTheme: IconThemeData(color: c.textSecondary, size: 22),
        titleTextStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.surfaceCard,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: c.surfaceBorder, width: 1.0),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceCard,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: TextStyle(
          color: c.textTertiary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: c.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.surfaceBorder, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.surfaceBorder, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.accentHoney, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: c.statusError, width: 1.0),
        ),
      ),
      chipTheme: ChipThemeData(
        elevation: 0,
        pressElevation: 0,
        backgroundColor: c.surfaceCard,
        selectedColor: c.surfaceSubtle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: c.surfaceBorder, width: 1.0),
        ),
        labelStyle: TextStyle(
          color: c.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          color: c.accentHoney,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accentHoney,
        foregroundColor: const Color(0xFF172B4D),
        elevation: 2,
        focusElevation: 3,
        hoverElevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.surfaceBorder,
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: c.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: c.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: c.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.15,
          height: 1.35,
          color: c.textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: c.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.45,
          color: c.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: c.textTertiary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: c.textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: c.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: c.textTertiary,
        ),
      ),
    );
  }
}
