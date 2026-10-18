import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'screens/landing/landing_page.dart';
import 'screens/public/public_pet_page.dart';
import 'screens/pets/accept_invitation_page.dart';
import 'screens/home/home_page.dart';

// ============================================================
// PAWLINK APP ENTRY POINT
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable clean path URLs on Flutter Web.
  // Example: /p/PET_ID instead of /#/p/PET_ID.
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
// PAWLINK APPLICATION
// ============================================================

class PawLink extends StatelessWidget {
  const PawLink({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PawLink',
      theme: _buildTheme(textTheme),

      // ======================================================
      // INITIAL URL ROUTING
      //
      // Public pet profile: /p/PET-ID
      // Joint-owner invitation: /invite/INVITATION-ID
      //
      // On Web, inspect the browser path before showing
      // the default authentication gate.
      // ======================================================

      onGenerateInitialRoutes: (initialRoute) {
        final String path = kIsWeb ? Uri.base.path : initialRoute;

        debugPrint('PAWLINK DEBUG: initialRoute = $initialRoute');
        debugPrint('PAWLINK DEBUG: browser path = ${Uri.base.path}');
        debugPrint('PAWLINK DEBUG: selected path = $path');

        return <Route<dynamic>>[
          _routeForPath(path),
        ];
      },

      // ======================================================
      // NORMAL NAMED ROUTING
      // ======================================================

      onGenerateRoute: (settings) {
        return _routeForPath(
          settings.name ?? '/',
          settings: settings,
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
  // GLOBAL THEME
  // ==========================================================

  ThemeData _buildTheme(TextTheme textTheme) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: PawLinkColors.teal,
        brightness: Brightness.light,
        primary: PawLinkColors.teal,
        secondary: PawLinkColors.orange,
        surface: PawLinkColors.surface,
        error: PawLinkColors.lost,
      ),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: PawLinkColors.background,
      textTheme: textTheme.apply(
        bodyColor: PawLinkColors.textPrimary,
        displayColor: PawLinkColors.textPrimary,
      ),
      primaryTextTheme: GoogleFonts.poppinsTextTheme(
        baseTheme.primaryTextTheme,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: PawLinkColors.background,
        foregroundColor: PawLinkColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: PawLinkColors.deepTeal,
        ),
        iconTheme: const IconThemeData(
          color: PawLinkColors.deepTeal,
          size: 23,
        ),
      ),
      cardTheme: CardThemeData(
        color: PawLinkColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: PawLinkColors.border,
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PawLinkColors.orange,
          foregroundColor: PawLinkColors.deepTeal,
          disabledBackgroundColor: PawLinkColors.border,
          disabledForegroundColor: PawLinkColors.textSecondary,
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
          foregroundColor: PawLinkColors.teal,
          side: const BorderSide(
            color: PawLinkColors.teal,
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
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
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PawLinkColors.teal,
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
        fillColor: PawLinkColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: PawLinkColors.textSecondary,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: PawLinkColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: PawLinkColors.teal,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: PawLinkColors.textSecondary,
        suffixIconColor: PawLinkColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: PawLinkColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: PawLinkColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: PawLinkColors.teal,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: PawLinkColors.lost,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: PawLinkColors.lost,
            width: 1.6,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PawLinkColors.surface,
        selectedItemColor: PawLinkColors.teal,
        unselectedItemColor: PawLinkColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: PawLinkColors.surface,
        indicatorColor: PawLinkColors.softTeal,
        elevation: 0,
        height: 70,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (states) {
            final selected = states.contains(WidgetState.selected);

            return GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color:
                  selected ? PawLinkColors.teal : PawLinkColors.textSecondary,
            );
          },
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: PawLinkColors.orange,
        foregroundColor: PawLinkColors.deepTeal,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: PawLinkColors.border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        backgroundColor: PawLinkColors.softTeal,
        selectedColor: PawLinkColors.teal.withValues(alpha: 0.12),
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: PawLinkColors.deepTeal,
        ),
        side: const BorderSide(
          color: PawLinkColors.border,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PawLinkColors.teal,
        linearTrackColor: PawLinkColors.border,
        circularTrackColor: PawLinkColors.border,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return PawLinkColors.teal;
            }

            return null;
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: PawLinkColors.deepTeal,
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: PawLinkColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: PawLinkColors.deepTeal,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          height: 1.5,
          color: PawLinkColors.textSecondary,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: PawLinkColors.deepTeal,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }
}

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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: PawLinkColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: PawLinkColors.teal,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            backgroundColor: PawLinkColors.background,
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to verify your session. '
                  'Please check your connection and restart the app.',
                  textAlign: TextAlign.center,
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
