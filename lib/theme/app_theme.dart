import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class AppColors {
  // Base colors
  static const Color base1 = Color(0xFF101010);
  static const Color base2 = Color(0xFF151515);

  // Text
  static const Color text1 = Color(0xFFFFFFFF);
  static const Color text2 = Color(0xB8FFFFFF); // 72%
  static const Color text3 = Color(0x7AFFFFFF); // 48%
  static const Color text4 = Color(0x3DFFFFFF); // 24%

  // Accent
  static const Color primaryAccent = Color(0xFF9196FF);
  static const Color secondaryAccent = Color(0xFF5691FF);

  // Surface
  static const Color surfaceBlack1 = Color(0xFF101010);
  static const Color surfaceBlack2 = Color(0xB3101010);
  static const Color surfaceBlack3 = Color(0x80101010);


  // Border shades
  static const Color border1 = Color(0x14FFFFFF); // 8%
  static const Color border2 = Color(0x28FFFFFF); // 16%
  static const Color border3 = Color(0x3DFFFFFF); // 24%
}

class AppTextStyles {
  static final TextStyle h1Bold = GoogleFonts.spaceGrotesk(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.03 * 28,
    color: AppColors.text1,
  );

  static final TextStyle h1Regular = GoogleFonts.spaceGrotesk(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.03 * 28,
    color: AppColors.text1,
  );

  static final TextStyle h2Bold = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 24,
    color: AppColors.text1,
  );

  static final TextStyle h2Regular = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.02 * 24,
    color: AppColors.text1,
  );

  static final TextStyle h3Bold = GoogleFonts.spaceGrotesk(
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01 * 20,
    color: AppColors.text1,
  );

  static final TextStyle h3Regular = GoogleFonts.spaceGrotesk(
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.01 * 20,
    color: AppColors.text1,
  );

  static final TextStyle body1Bold = GoogleFonts.spaceGrotesk(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: AppColors.text1,
  );

  static final TextStyle body1Regular = GoogleFonts.spaceGrotesk(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.text1,
  );

  static final TextStyle body2Bold = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w700,
    color: AppColors.text1,
  );

  static final TextStyle body2Regular = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.text1,
  );

  static final TextStyle subtextBold = GoogleFonts.spaceGrotesk(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w700,
    color: AppColors.text2,
  );

  static final TextStyle subtextRegular = GoogleFonts.spaceGrotesk(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    color: AppColors.text3,
  );
}


class AppTheme {
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppColors.base1,
    primaryColor: AppColors.primaryAccent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.text1),
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1Bold,
      displayMedium: AppTextStyles.h2Bold,
      bodyLarge: AppTextStyles.body1Regular,
      bodyMedium: AppTextStyles.body2Regular,
      labelSmall: AppTextStyles.subtextRegular,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.base2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryAccent),
      ),
      hintStyle: AppTextStyles.subtextRegular,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surfaceBlack2,
        foregroundColor: AppColors.text1,
        textStyle: AppTextStyles.body1Bold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}
