
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';

import 'seasonal/seasonal_controller.dart';
import 'seasonal/seasonal_theme.dart';
import 'seasonal/seasonal_overlay.dart';
import 'seasonal/seasonal_navigation.dart';
import 'seasonal/seasonal_shop_page.dart';

import 'firebase_options.dart';
import 'screens/landing/landing_page.dart';
import 'screens/public/public_pet_page.dart';
import 'screens/pets/accept_invitation_page.dart';
import 'screens/home/home_page.dart';
import 'screens/admin/barangay_admin_page.dart';

// ============================================================
// PAWLINK APP ENTRY POINT
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await SeasonalController.instance.initialize();

  // Load saved theme preference before opening PawLink.
  await PawLinkTheme.load();

  runApp(const PawLink());
}

// ============================================================
// PAWLINK BRAND COLORS
// ============================================================

class PawLinkColors {
  PawLinkColors._();

  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color teal = Color(0xFF0A7E8C);
  static const Color darkTeal = Color(0xFF075C65);
  static const Color deepTeal = Color(0xFF064B52);

  static const Color orange = Color(0xFFFF9F43);
  static const Color orangeDark = Color(0xFFE8892D);

  static const Color lost = Color(0xFFEE5253);
  static const Color found = Color(0xFF10AC84);
  static const Color qrBlue = Color(0xFF2E86DE);

  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color softTeal = Color(0xFFF0F8F8);
  static const Color inputBackground = Color(0xFFF9FAFB);
}

// ============================================================
// PAWLINK THEME PREFERENCE
// ============================================================

class PawLinkTheme {
  static final ValueNotifier<ThemeMode> mode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    mode.value = prefs.getBool('darkMode') == true
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  static Future<void> setDarkMode(bool enabled) async {
    mode.value = enabled ? ThemeMode.dark : ThemeMode.light;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', enabled);
  }
}

// ============================================================
// PAWLINK APPLICATION
// ============================================================

class PawLink extends StatefulWidget {
  const PawLink({super.key});

  @override
  State<PawLink> createState() => _PawLinkState();
}

class _PawLinkState extends State<PawLink> {
  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    );

    return AnimatedBuilder(
      animation: SeasonalController.instance,
      builder: (context, _) {
        final activeTheme = SeasonalController.instance.activeTheme;

        return ValueListenableBuilder<ThemeMode>(
          valueListenable: PawLinkTheme.mode,
          builder: (context, themeMode, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'PawLink',
              navigatorKey: pawLinkNavigatorKey,
              theme: _buildTheme(textTheme, activeTheme),
              darkTheme: _buildDarkTheme(textTheme),
              themeMode: themeMode,
              themeAnimationDuration: const Duration(milliseconds: 350),
              builder: (context, child) => SeasonalOverlay(
                child: child ?? const SizedBox.shrink(),
              ),
              onGenerateInitialRoutes: (initialRoute) {
                final String path =
                    kIsWeb ? Uri.base.path : initialRoute;

                debugPrint('PAWLINK DEBUG: initialRoute = $initialRoute');
                debugPrint('PAWLINK DEBUG: browser path = ${Uri.base.path}');
                debugPrint('PAWLINK DEBUG: selected path = $path');

                return <Route<dynamic>>[
                  _routeForPath(path),
                ];
              },
              onGenerateRoute: (settings) {
                return _routeForPath(
                  settings.name ?? '/',
                  settings: settings,
                );
              },
            );
          },
        );
      },
    );
  }
  // ==========================================================
  // ROUTE HANDLER
  // ==========================================================

  Route<dynamic> _routeForPath(
    String path, {
    RouteSettings? settings,
  }) {
    debugPrint('PAWLINK DEBUG: _routeForPath received = $path');

    final Uri? uri = Uri.tryParse(path);
    final List<String> segments = uri?.pathSegments ?? const [];

    // --------------------------------------------------------
    // PUBLIC PET PROFILE
    // URL format: /p/PET-ID
    // --------------------------------------------------------

    if (segments.length == 2 &&
        segments[0].toLowerCase() == 'p' &&
        segments[1].isNotEmpty) {
      final String petId = segments[1];

      return MaterialPageRoute<dynamic>(
        settings: settings ?? RouteSettings(name: path),
        builder: (_) => PublicPetPage(
          petId: petId,
        ),
      );
    }

    // --------------------------------------------------------
    // JOINT-OWNER INVITATION
    // URL format: /invite/INVITATION-ID
    // --------------------------------------------------------

    if (segments.length == 2 &&
        segments[0].toLowerCase() == 'invite' &&
        segments[1].isNotEmpty) {
      final String invitationId = segments[1];

      return MaterialPageRoute<dynamic>(
        settings: settings ?? RouteSettings(name: path),
        builder: (_) => AcceptInvitationPage(
          invitationId: invitationId,
        ),
      );
    }

    // --------------------------------------------------------
    // BARANGAY ADMIN PAGE
    // URL format: /admin/barangay
    // --------------------------------------------------------

    if (segments.length == 2 &&
        segments[0].toLowerCase() == 'admin' &&
        segments[1].toLowerCase() == 'barangay') {
      return MaterialPageRoute<dynamic>(
        settings: settings ?? RouteSettings(name: path),
        builder: (_) => const BarangayAdminPage(),
      );
    }

    // --------------------------------------------------------
    // SEASONAL THEME SHOP
    // URL format: /themes
    // --------------------------------------------------------

    if (segments.length == 1 && segments[0].toLowerCase() == 'themes') {
      return MaterialPageRoute<dynamic>(
        settings: settings ?? RouteSettings(name: path),
        builder: (_) => const SeasonalShopPage(),
      );
    }

    // --------------------------------------------------------
    // DEFAULT APPLICATION PAGE
    //
    // Logged-in users -> HomePage
    // Logged-out users -> LandingPage
    // --------------------------------------------------------

    return MaterialPageRoute<dynamic>(
      settings: settings ?? RouteSettings(name: path),
      builder: (_) => const AuthGate(),
    );
  }

  // ==========================================================
  // LIGHT THEME
  // ==========================================================

  ThemeData _buildTheme(
    TextTheme textTheme,
    SeasonalTheme? seasonalTheme,
  ) {
    // Fall back to PawLink's original teal-and-orange brand palette.
    final primary = seasonalTheme?.primary ?? PawLinkColors.teal;
    final secondary = seasonalTheme?.secondary ?? PawLinkColors.orange;
    final background = seasonalTheme?.background ?? PawLinkColors.background;
    final surface = seasonalTheme?.surface ?? PawLinkColors.surface;
    final onPrimary = seasonalTheme?.onPrimary ?? PawLinkColors.deepTeal;
    final textPrimary = seasonalTheme?.textPrimary ?? PawLinkColors.textPrimary;
    final textSecondary =
        seasonalTheme?.textSecondary ?? PawLinkColors.textSecondary;
    final border = seasonalTheme?.border ?? PawLinkColors.border;
    final softSurface = Color.alphaBlend(
      primary.withValues(alpha: 0.08),
      surface,
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        surface: surface,
        error: PawLinkColors.lost,
      ),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      primaryTextTheme: GoogleFonts.poppinsTextTheme(
        baseTheme.primaryTextTheme,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        iconTheme: IconThemeData(color: primary, size: 23),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          disabledBackgroundColor: border,
          disabledForegroundColor: textSecondary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          minimumSize: const Size(48, 48),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          minimumSize: const Size(48, 48),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: textSecondary,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: primary,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PawLinkColors.lost),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: PawLinkColors.lost,
            width: 1.6,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: softSurface,
        elevation: 0,
        height: 70,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (states) {
            final selected = states.contains(WidgetState.selected);
            return GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? primary : textSecondary,
);
          },
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondary,
        foregroundColor: onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        backgroundColor: softSurface,
        selectedColor: primary.withValues(alpha: 0.12),
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: border,
        circularTrackColor: border,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) return primary;
            return null;
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textPrimary,
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          height: 1.5,
          color: textSecondary,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textPrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  // ==========================================================
  // DARK THEME
  // ==========================================================

  ThemeData _buildDarkTheme(TextTheme textTheme) {
    const darkBackground = Color(0xFF121A1B);
    const darkSurface = Color(0xFF1D292A);
    const darkSurfaceLight = Color(0xFF293A3B);
    const darkBorder = Color(0xFF344344);

    const darkText = Color(0xFFF1F5F5);
    const secondaryText = Color(0xFFB0C0C0);

    const primaryTeal = Color(0xFF2DD4BF);
    const orange = Color(0xFFFFB15C);

    final darkScheme = ColorScheme.fromSeed(
      seedColor: PawLinkColors.teal,
      brightness: Brightness.dark,
      primary: primaryTeal,
      secondary: orange,
      surface: darkSurface,
      error: const Color(0xFFFF6B6B),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: darkBackground,

      textTheme: GoogleFonts.poppinsTextTheme(textTheme).apply(
        bodyColor: darkText,
        displayColor: darkText,
      ),

      primaryTextTheme: GoogleFonts.poppinsTextTheme(),

      visualDensity: VisualDensity.adaptivePlatformDensity,

      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: darkBorder),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orange,
          foregroundColor: const Color(0xFF243333),
          disabledBackgroundColor: darkBorder,
          disabledForegroundColor: secondaryText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 15,
          ),
          minimumSize: const Size(48, 48),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTeal,
          side: const BorderSide(
            color: primaryTeal,
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryTeal,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: secondaryText),
        labelStyle: const TextStyle(color: secondaryText),
        floatingLabelStyle: const TextStyle(color: primaryTeal),
        prefixIconColor: secondaryText,
        suffixIconColor: secondaryText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: primaryTeal,
            width: 1.6,
          ),
        ),
      ),

      bottomNavigationBarTheme:
          const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryTeal,
        unselectedItemColor: secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: primaryTeal.withValues(alpha: 0.18),
        elevation: 0,
        height: 70,
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(
            fontSize: 11,
            color: darkText,
          ),
        ),
      ),

      floatingActionButtonTheme:
          FloatingActionButtonThemeData(
        backgroundColor: orange,
        foregroundColor: const Color(0xFF243333),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceLight,
        selectedColor: primaryTeal.withValues(alpha: 0.2),
        labelStyle: const TextStyle(
          color: darkText,
          fontSize: 12,
        ),
        side: const BorderSide(color: darkBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      progressIndicatorTheme:
          const ProgressIndicatorThemeData(
        color: primaryTeal,
        linearTrackColor: darkBorder,
        circularTrackColor: darkBorder,
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return primaryTeal;
            }
            return darkSurfaceLight;
          },
        ),
        checkColor: WidgetStateProperty.all(darkBackground),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return primaryTeal;
            }
            return secondaryText;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return primaryTeal.withValues(alpha: 0.3);
            }
            return darkSurfaceLight;
          },
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: darkSurfaceLight,
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: darkText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          height: 1.5,
          color: secondaryText,
        ),
      ),

      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: darkSurfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: darkText,
        ),
      ),

      listTileTheme: const ListTileThemeData(
        textColor: darkText,
        iconColor: primaryTeal,
      ),

       iconTheme: const IconThemeData(
        color: secondaryText,
      ),
    );
  } // End of _buildDarkTheme()

} // End of _PawLinkStateEnd of _PawLinkState

// ============================================================
// AUTHENTICATION GATE
//
// Logged in  -> HomePage
// Logged out -> LandingPage
//
// Firebase authStateChanges() automatically updates the page
// after login, registration, or FirebaseAuth.signOut().
// ============================================================


  class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Unable to verify your session. '
                  'Please check your connection and restart the app.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          return const HomePage();
        }

        return const LandingPage();
      },
    );
  }
}