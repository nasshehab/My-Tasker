// lib/utils/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Brand Colors (Light Theme) ───────────────────────────────────────────────
class C {
  // Primary brand
  static const accent      = Color(0xFFD64E6F); // deep rose-red
  static const accentLight = Color(0xFFFCE8ED); // very light rose
  static const accentMid   = Color(0xFFF2A0B4); // mid rose

  // Background tones
  static const bg          = Color(0xFFF7F4F0); // warm off-white
  static const bgAlt       = Color(0xFFFFFBF8); // almost white
  static const card        = Color(0xFFFFFFFF); // pure white cards
  static const card2       = Color(0xFFF4F0EC); // light grey card

  // Text
  static const text        = Color(0xFF1A1A1A);
  static const textSub     = Color(0xFF6B6B6B);
  static const textHint    = Color(0xFFAAAAAA);

  // Status
  static const green       = Color(0xFF2D9E5A);
  static const greenLight  = Color(0xFFE8F7EE);
  static const red         = Color(0xFFD63B3B);
  static const redLight    = Color(0xFFFDE8E8);
  static const yellow      = Color(0xFFE59C0A);
  static const yellowLight = Color(0xFFFFF4D9);
  static const blue        = Color(0xFF2563EB);
  static const blueLight   = Color(0xFFEBF2FF);
  static const purple      = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFF3EEFF);
  static const orange      = Color(0xFFEA580C);
  static const orangeLight = Color(0xFFFEF0E7);
  static const teal        = Color(0xFF0891B2);
  static const tealLight   = Color(0xFFE6F6FA);

  // Borders & dividers
  static const border      = Color(0xFFE8E2DC);
  static const divider     = Color(0xFFF0EBE5);

  // Primary (mapped to accent for brand consistency)
  static const primary     = Color(0xFF1B4FBE);   // royal blue
  static const primaryDim  = Color(0xFFEAF0FF);   // light blue tint

  // Surface aliases
  static const surface     = Color(0xFFFFFFFF);   // pure white
  static const surface2    = Color(0xFFF4F0EC);   // light card
  static const white       = Color(0xFFFFFFFF);

  // Dim/light variants (used by badges)
  static const redDim      = Color(0xFFFDE8E8);
  static const greenDim    = Color(0xFFE8F7EE);
  static const yellowDim   = Color(0xFFFFF4D9);
  static const blueDim     = Color(0xFFEBF2FF);
  static const purpleDim   = Color(0xFFF3EEFF);
  static const tealDim     = Color(0xFFE6F6FA);
  static const accentDim   = Color(0xFFFCE8ED);

  // 12-color category palette
  static const List<Color> palette = [
    Color(0xFFD64E6F), Color(0xFF2D9E5A), Color(0xFF2563EB),
    Color(0xFF7C3AED), Color(0xFFEA580C), Color(0xFF0891B2),
    Color(0xFFE59C0A), Color(0xFFD63B3B), Color(0xFF0D9488),
    Color(0xFF9333EA), Color(0xFF16A34A), Color(0xFF1D4ED8),
  ];
  static const List<Color> paletteLight = [
    Color(0xFFFCE8ED), Color(0xFFE8F7EE), Color(0xFFEBF2FF),
    Color(0xFFF3EEFF), Color(0xFFFEF0E7), Color(0xFFE6F6FA),
    Color(0xFFFFF4D9), Color(0xFFFDE8E8), Color(0xFFE6FAF8),
    Color(0xFFF5EEFF), Color(0xFFE8FAF0), Color(0xFFE8EEFF),
  ];

  static Color byIndex(int i) => palette[i % palette.length];
  static Color lightByIndex(int i) => paletteLight[i % paletteLight.length];
}

// ─── App Constants ────────────────────────────────────────────────────────────
class K {
  static const appName     = 'মাই ট্যাস্কার';
  static const boxProfile  = 'mt_profile';
  static const boxCats     = 'mt_cats';
  static const boxSubs     = 'mt_subs';
  static const boxTasks    = 'mt_tasks';
  static const boxSessions = 'mt_sessions';
  static const boxHabits   = 'mt_habits';
  static const boxHistory  = 'mt_history';
  static const boxPlans    = 'mt_plans';
  static const boxSettings = 'mt_settings';

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  static String fmtTime(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final s = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $s';
  }

  static String fmtDate(DateTime d) {
    const months = [
      'জানু','ফেব্রু','মার্চ','এপ্রিল','মে','জুন',
      'জুলাই','আগস্ট','সেপ্টে','অক্টো','নভে','ডিসে'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static String fmtDateFull(DateTime d) {
    const months = [
      'জানুয়ারি','ফেব্রুয়ারি','মার্চ','এপ্রিল','মে','জুন',
      'জুলাই','আগস্ট','সেপ্টেম্বর','অক্টোবর','নভেম্বর','ডিসেম্বর'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static String fmtDuration(int minutes) {
    if (minutes <= 0) return '০ মি';
    if (minutes < 60) return '${minutes} মি';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h} ঘ' : '${h} ঘ ${m} মি';
  }

  static String monthName(int month) {
    const months = [
      'জানুয়ারি','ফেব্রুয়ারি','মার্চ','এপ্রিল','মে','জুন',
      'জুলাই','আগস্ট','সেপ্টেম্বর','অক্টোবর','নভেম্বর','ডিসেম্বর'
    ];
    return months[month - 1];
  }

  static String tobn(dynamic n) {
    const en = ['0','1','2','3','4','5','6','7','8','9'];
    const bn = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
    var result = n.toString();
    for (int i = 0; i < en.length; i++) {
      result = result.replaceAll(en[i], bn[i]);
    }
    return result;
  }
}

// ─── App Theme (Light) ────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get light {
    final bengaliTextTheme = const TextTheme(
        displayLarge:   TextStyle(color: C.text, fontWeight: FontWeight.w700, fontFamily: 'AbuJMAkkas'),
        headlineLarge:  TextStyle(color: C.text, fontWeight: FontWeight.w700, fontSize: 24, fontFamily: 'AbuJMAkkas'),
        headlineMedium: TextStyle(color: C.text, fontWeight: FontWeight.w600, fontSize: 20, fontFamily: 'AbuJMAkkas'),
        titleLarge:     TextStyle(color: C.text, fontWeight: FontWeight.w600, fontSize: 17, fontFamily: 'AbuJMAkkas'),
        titleMedium:    TextStyle(color: C.text, fontWeight: FontWeight.w500, fontSize: 15, fontFamily: 'AbuJMAkkas'),
        bodyLarge:      TextStyle(color: C.text, fontSize: 15, fontFamily: 'AbuJMAkkas'),
        bodyMedium:     TextStyle(color: C.textSub, fontSize: 13, fontFamily: 'AbuJMAkkas'),
        labelLarge:     TextStyle(color: C.text, fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'AbuJMAkkas'),
      );
    return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: C.bg,
    colorScheme: const ColorScheme.light(
      primary: C.accent,
      secondary: C.green,
      surface: C.card,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: C.text,
    ),
    textTheme: bengaliTextTheme,
    fontFamily: 'AbuJMAkkas',
    appBarTheme: AppBarTheme(
      backgroundColor: C.bgAlt,
      foregroundColor: C.text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontFamily: 'AbuJMAkkas',
        color: C.text,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF7F4F0),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    ),
    cardTheme: CardTheme(
      color: C.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: C.border, width: 1),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: C.bgAlt,
      selectedItemColor: C.accent,
      unselectedItemColor: C.textHint,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700),
      unselectedLabelStyle: TextStyle(fontSize: 10),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.card2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: C.accent, width: 1.5),
      ),
      hintStyle: const TextStyle(
        color: C.textHint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: C.divider, thickness: 1, space: 1),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: C.accent,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );
  }
}