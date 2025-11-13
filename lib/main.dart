import 'package:flutter/material.dart';
import 'services/firebase_service.dart';
import 'screens/trip_signin_screen.dart';
import 'ui/app_theme.dart';

// TODO: Before running the app:
// 1. Create a Firebase project at https://console.firebase.google.com
// 2. Enable Firestore Database
// 3. Add your app (Android/iOS) to Firebase project
// 4. Download google-services.json (Android) and GoogleService-Info.plist (iOS)
// 5. Update config/firebase_config.dart with your Firebase credentials
// 6. Run 'flutter pub get' to install dependencies

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await FirebaseService().initializeFirebase();
    print('✅ Firebase initialized successfully in main');
  } catch (e, stackTrace) {
    print('❌ Firebase initialization error: $e');
    print('Stack trace: $stackTrace');
    // Continue anyway to allow UI to show error messages
  }
  
  runApp(const PayUpApp());
}

class PayUpApp extends StatelessWidget {
  const PayUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const TripSignInScreen(),
    );
  }
}
