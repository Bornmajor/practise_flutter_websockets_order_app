import 'package:flutter/material.dart';

/// UI Constants for consistent styling across the app
class UIConstants {
  // ========== BORDER RADIUS ==========
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Pre-built BorderRadius objects
  static final BorderRadius borderRadiusSmall = BorderRadius.circular(
    radiusSmall,
  );
  static final BorderRadius borderRadiusMedium = BorderRadius.circular(
    radiusMedium,
  );
  static final BorderRadius borderRadiusLarge = BorderRadius.circular(
    radiusLarge,
  );
  static final BorderRadius borderRadiusXLarge = BorderRadius.circular(
    radiusXLarge,
  );

  // ========== SPACING ==========
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // static const double spacingPageItemsMedium = 16.0;
  // static const double spacingPageItemsSmall = 8.0;

  // ========== PADDING ==========
  static const EdgeInsets paddingXSmall = EdgeInsets.all(spacingXSmall);
  static const EdgeInsets paddingSmall = EdgeInsets.all(spacingSmall);
  static const EdgeInsets paddingMedium = EdgeInsets.all(spacingMedium);
  static const EdgeInsets paddingLarge = EdgeInsets.all(spacingLarge);

  static const EdgeInsets paddingHorizontalSmall = EdgeInsets.symmetric(
    horizontal: spacingSmall,
  );
  static const EdgeInsets paddingHorizontalMedium = EdgeInsets.symmetric(
    horizontal: spacingMedium,
  );
  static const EdgeInsets paddingHorizontalLarge = EdgeInsets.symmetric(
    horizontal: spacingLarge,
  );

  static const EdgeInsets paddingVerticalSmall = EdgeInsets.symmetric(
    vertical: spacingSmall,
  );
  static const EdgeInsets paddingVerticalMedium = EdgeInsets.symmetric(
    vertical: spacingMedium,
  );
  static const EdgeInsets paddingVerticalLarge = EdgeInsets.symmetric(
    vertical: spacingLarge,
  );

  static const EdgeInsets cardPaddingMedium = EdgeInsets.all(spacingMedium);
  static const EdgeInsets cardPaddingSmall = EdgeInsets.all(spacingSmall);
  static const EdgeInsets cardPaddingXSmall = EdgeInsets.symmetric(horizontal:spacingSmall,vertical: spacingXSmall);

  static const EdgeInsets pillPaddingMedium = EdgeInsets.symmetric(
    horizontal: spacingSmall,
    vertical: spacingXSmall,
  );

  static const EdgeInsets buttonPaddingMedium = EdgeInsets.symmetric(
    horizontal: spacingLarge,
    vertical: spacingMedium,
  );
  
  static const EdgeInsets inputFieldPaddingMedium = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: spacingSmall,
  );

  // ========== SIZES ==========
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  static const double buttonHeight = 50.0;
  static const double inputHeight = 56.0;
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 40.0;
  static const double avatarSizeLarge = 64.0;

  // ========== ELEVATION ==========
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // ========== BORDER WIDTH ==========
  static const double borderWidthThin = 1.0;
  static const double borderWidthMedium = 1.5;
  static const double borderWidthThick = 2.0;

  // TODO: Add animation duration constants if needed in future
  // ========== ANIMATION DURATION ==========
  // static const Duration animationFast = Duration(milliseconds: 150);
  // static const Duration animationNormal = Duration(milliseconds: 300);
  // static const Duration animationSlow = Duration(milliseconds: 500);
}
