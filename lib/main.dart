import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/landing/landing_page.dart';
import 'screens/public/public_pet_page.dart';
import 'screens/pets/accept_invitation_page.dart';
import 'screens/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PawLink());
}

class PawLink extends StatelessWidget {
  const PawLink({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'PawLink',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFBF5),
        fontFamily: 'Roboto',
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFBF5),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),

      // ============================================================
      // WEB URL ROUTING
      // ============================================================

      onGenerateRoute: (settings) {
        final uri = Uri.base;
        final segments = uri.pathSegments;

        // ==========================================================
        // PUBLIC PET PROFILE
        //
        // /p/PET-ID
        //
        // This page is available without logging in.
        // ==========================================================

        if (segments.length == 2 && segments[0].toLowerCase() == 'p') {
          final petId = segments[1];

          if (petId.isNotEmpty) {
            return MaterialPageRoute(
              builder: (_) => PublicPetPage(
                petId: petId,
              ),
            );
          }
        }

        // ==========================================================
        // JOINT OWNER INVITATION
        //
        // /invite/INVITATION-ID
        // ==========================================================

        if (segments.length == 2 && segments[0].toLowerCase() == 'invite') {
          final invitationId = segments[1];

          if (invitationId.isNotEmpty) {
            return MaterialPageRoute(
              builder: (_) => AcceptInvitationPage(
                invitationId: invitationId,
              ),
            );
          }
        }

        return null;
      },

      // ============================================================
      // AUTHENTICATION GATE
      // ============================================================
      //
      // Logged in:
      //     HomePage
      //
      // Logged out:
      //     LandingPage
      //
      // Firebase authStateChanges() automatically reacts when
      // FirebaseAuth.signOut() is called.
      // ============================================================

      home: const AuthGate(),
    );
  }
}

// ================================================================
// AUTH GATE
// ================================================================
//
// This is the single source of truth for whether the user is
// authenticated.
//
// FirebaseAuth.authStateChanges() emits:
//   User   -> logged in
//   null   -> logged out
//
// ================================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ========================================================
        // INITIAL AUTH CHECK
        // ========================================================

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFFBF5),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0F766E),
              ),
            ),
          );
        }

        // ========================================================
        // LOGGED IN
        // ========================================================

        final user = snapshot.data;

        if (user != null) {
          return const HomePage();
        }

        // ========================================================
        // LOGGED OUT
        // ========================================================

        return const LandingPage();
      },
    );
  }
}
