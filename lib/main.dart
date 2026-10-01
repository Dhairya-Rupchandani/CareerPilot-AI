import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'services/firestore_service.dart';

import 'screens/auth/login_screen.dart';
import 'screens/assessment/assessment_screen.dart';
import 'screens/home/home_screen.dart';

import 'widgets/internet_required.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CareerPilotApp());
}

class CareerPilotApp extends StatelessWidget {
  const CareerPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CareerPilot AI',

      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),

      home: const InternetRequired(
        child: AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!authSnapshot.hasData) {
          return const LoginScreen();
        }

        return FutureBuilder<bool>(
          future: FirestoreService().isAssessmentCompleted(),

          builder: (context, assessmentSnapshot) {
            if (assessmentSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (assessmentSnapshot.data == true) {
              return const HomeScreen();
            }

            return const AssessmentScreen();
          },
        );
      },
    );
  }
}