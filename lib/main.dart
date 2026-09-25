import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/landing/landing_page.dart';
import 'screens/public/public_pet_page.dart';
import 'screens/pets/accept_invitation_page.dart';

// Import your dashboard page here.
// Change this import only if your actual dashboard file is located elsewhere.
import 'screens/home/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),

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

      // ========================================================
      // WEB URL ROUTING
      // ========================================================
      onGenerateRoute: (settings) {
        final uri = Uri.base;
        final segments = uri.pathSegments;

        // ------------------------------------------------------
        // PUBLIC PET PROFILE
        //
        // /p/PET-ID
        //
        // This page remains publicly accessible even without login.
        // ------------------------------------------------------

        if (segments.length == 2 && segments[0].toLowerCase() == 'p') {
          final petId = segments[1];

          if (petId.isNotEmpty) {
            return MaterialPageRoute(
              builder: (context) => PublicPetPage(petId: petId),
            );
          }
        }

        // ------------------------------------------------------
        // JOINT OWNER INVITATION
        //
        // /invite/INVITATION-ID
        // ------------------------------------------------------

        if (segments.length == 2 && segments[0].toLowerCase() == 'invite') {
          final invitationId = segments[1];

          if (invitationId.isNotEmpty) {
            return MaterialPageRoute(
              builder: (context) =>
                  AcceptInvitationPage(invitationId: invitationId),
            );
          }
        }

        return null;
      },

      // ========================================================
      // AUTHENTICATION GATE
      // ========================================================
      //
      // Firebase decides which page the user should see:
      //
      // Logged in  -> Dashboard
      // Logged out -> Landing Page
      //
      // This also handles refreshing the browser.
      // ========================================================
      home: const AuthGate(),
    );
  }
}

// ================================================================
// AUTH GATE
// ================================================================
//
// This listens to Firebase Authentication.
//
// If the user is logged in:
//     show Dashboard
//
// If the user is logged out:
//     show Landing Page
//
// ================================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // ------------------------------------------------------
        // Firebase is still checking the authentication state.
        // ------------------------------------------------------

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFFFFBF5),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF0F766E)),
            ),
          );
        }

        // ------------------------------------------------------
        // User is logged in.
        // ------------------------------------------------------

        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        }

        // ------------------------------------------------------
        // User is logged out.
        // ------------------------------------------------------

        return const LandingPage();
      },
    );
  }
}
