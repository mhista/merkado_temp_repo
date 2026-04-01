import 'package:flutter/material.dart';
import 'package:merkado_ds/merkado_ds.dart';

class MycutTheme {
  MycutTheme._();

  static ThemeData get light => MerkadoThemeBuilder.build(
        isDark: false,
        config: MerkadoThemeConfig(
            colors: AppColorScheme.fromMycut(isDark: false),
            // fontFamilyOverride:
            //     MerkadoFonts.mycut, //.mycut uses Instrument sa
            
            buttonBorderRadius: 999.0,
            elevatedButtonOverride: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                foregroundColor: Colors.white,
                backgroundColor: MycutLightColors.brandPrimary,
                disabledForegroundColor:
                    MycutLightColors.brandPrimary.withValues(alpha: 0.8),
                disabledBackgroundColor: MycutDarkColors.borderDefault,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: TextStyle(
                  fontFamily: SemanticTypography.buttonFontFamily,
                  fontSize: SemanticTypography.buttonFontSize,
                  fontWeight: FontWeight
                      .values[SemanticTypography.buttonFontWeight ~/ 100 - 1],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            outlinedButtonOverride: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                elevation: 0,
                foregroundColor: Colors.white,
                backgroundColor: MycutLightColors.backgroundPrimary,
                disabledForegroundColor: MycutLightColors.stateInactive,
                disabledBackgroundColor: MycutLightColors.stateInactive,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                textStyle: TextStyle(
                  fontFamily: SemanticTypography.buttonFontFamily,
                  fontSize: SemanticTypography.buttonFontSize,
                  fontWeight: FontWeight
                      .values[SemanticTypography.buttonFontWeight ~/ 100 - 1],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ), // Everything else falls back to defaults — done.
            textThemeOverride: MycutTextTheme.light),
      );

  static ThemeData get dark => light;
  
  //  MerkadoThemeBuilder.build(
  //       isDark: false,
  //       config: MerkadoThemeConfig(
          
  //           colors: AppColorScheme.fromMycut(isDark: true),
  //           // fontFamilyOverride:
  //           //     MerkadoFonts.mycut, //.mycut uses Instrument sans
  //           buttonBorderRadius: 999.0,
  //           elevatedButtonOverride: ElevatedButtonThemeData(
  //             style: ElevatedButton.styleFrom(
  //               elevation: 0,
  //               foregroundColor: Colors.transparent,
  //               backgroundColor: MycutLightColors.brandPrimary,
  //               disabledForegroundColor:
  //                   MycutLightColors.brandPrimary.withValues(alpha: 0.8),
  //               disabledBackgroundColor: MycutDarkColors.borderDefault,
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  //               textStyle: TextStyle(
  //                 fontFamily: SemanticTypography.buttonFontFamily,
  //                 fontSize: SemanticTypography.buttonFontSize,
  //                 fontWeight: FontWeight
  //                     .values[SemanticTypography.buttonFontWeight ~/ 100 - 1],
  //               ),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(6),
  //               ),
  //             ),
  //           ),
  //           outlinedButtonOverride: OutlinedButtonThemeData(
  //             style: OutlinedButton.styleFrom(
  //               elevation: 0,
  //               foregroundColor: Colors.transparent,
  //               backgroundColor: Colors.transparent,
  //               disabledForegroundColor: MycutLightColors.stateInactive,
  //               disabledBackgroundColor: MycutLightColors.stateInactive,
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  //               textStyle: TextStyle(
  //                 fontFamily: SemanticTypography.buttonFontFamily,
  //                 fontSize: SemanticTypography.buttonFontSize,
  //                 fontWeight: FontWeight
  //                     .values[SemanticTypography.buttonFontWeight ~/ 100 - 1],
  //               ),
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(6),
  //                   side: const BorderSide(color: MycutLightColors.brandPrimary)),
  //             ),
  //           ),
  //           textThemeOverride: MycutTextTheme.light),
  //     );
}
