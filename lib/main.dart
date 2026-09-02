import 'package:app/login/auth.dart';
import 'package:app/homepage/home_page.dart';
import 'package:app/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/profile_picture_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'package:app/services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ App-wide fallback for widget-build-time crashes (e.g. a rare AI/network
  // interop error deep in a plugin). Without this, Flutter falls back to a
  // near-blank gray box in release builds — this shows something the user
  // can actually act on instead.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Please go back and try again.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  };

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _activateAppCheck();
  await NotificationService.initialize();
  await NotificationService.startClassTimeMonitoring(); // 👈 Auto-start monitoring
  runApp(MyApp());
}

// Activates Firebase App Check (native attestation only) so any App
// Check-protected Firebase service accepts requests from this app.
//   - Debug builds use the debug provider: on first run it prints a debug
//     token to the console that you register once in Firebase Console →
//     App Check → Apps → (this app) → Manage debug tokens, so local/dev
//     builds keep working without needing real device attestation.
//   - Release builds use Play Integrity (Android) / App Attest (iOS/macOS)
//     — real attestation, no debug token involved.
//   - Web is intentionally skipped here: Firebase's JS App Check SDK has a
//     bug where it calls reCAPTCHA Enterprise's execute() with the site-key
//     string instead of a rendered widget ID, which Google's API rejects
//     every time (confirmed directly against the reCAPTCHA Enterprise
//     assessment API — see the long comment in web/index.html). Nothing
//     else in this app enforces App Check, so web just uses its own working
//     token flow, wired up in lib/services/gemini_service.dart, instead of
//     going through this broken path.
// Wrapped in try/catch because App Check has no provider for Windows/Linux
// desktop; activation there would otherwise throw and block app startup.
Future<void> _activateAppCheck() async {
  if (kIsWeb) return;
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider:
          kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
    );
  } catch (e) {
    if (kDebugMode) print('⚠️ App Check activation skipped/failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfilePictureProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Study App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.mode,
            // ✅ ADD: Routes for notification navigation
            routes: {
              '/': (context) => const Auth(),
              '/login': (context) => LoginScreen(onTap: () {}),
              '/home': (context) => const HomePage(),
              '/classes': (context) => const HomePage(), // Navigate to classes tab
              '/schedule': (context) => const HomePage(), // Navigate to schedule tab
            },
            initialRoute: '/',
            onUnknownRoute: (settings) {
              if (kDebugMode) print('🔄 Unknown route: ${settings.name}');
              return MaterialPageRoute(
                builder: (context) => LoginScreen(onTap: () {}),
              );
            },
          );
        },
      ),
    );
  }
}
