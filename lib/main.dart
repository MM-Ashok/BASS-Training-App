import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/user_model.dart';
import 'providers/auth_provider.dart';
import 'providers/programme_provider.dart';
import 'providers/task_provider.dart';
import 'providers/ski_hours_provider.dart';
import 'providers/feedback_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/message_provider.dart';
import 'providers/branding_provider.dart';
import 'services/offline_service.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/super_admin/super_admin_dashboard.dart';
import 'screens/head_coach/head_coach_dashboard.dart';
import 'screens/coach/coach_dashboard.dart';
import 'screens/trainee/trainee_dashboard.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'firebase_options.dart';

final OfflineService offlineService = OfflineService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // NOTE: Firebase.initializeOptions requires the generated
  // firebase_options.dart (produced by `flutterfire configure`), which is
  // intentionally not included in this scaffold since it's tied to a real
  // Firebase project. Run `flutterfire configure` before first launch —
  // see README.md "Firebase setup".
  try {
    // await Firebase.initializeApp();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint(
        'Firebase not configured yet — run `flutterfire configure`. ($e)');
  }

  await offlineService.init();

  // Wires the offline outbox queue to actually replay against Firestore
  // once connectivity returns. See AttendanceProvider for a write-path
  // example that queues through this when offline.
  offlineService.onProcessWrite = (write) async {
    final db = FirebaseFirestore.instance;
    final collection = db.collection(write.collectionPath);
    switch (write.operation) {
      case PendingWriteOp.create:
        await collection.add(write.data);
        break;
      case PendingWriteOp.update:
        if (write.docId != null) {
          await collection
              .doc(write.docId)
              .set(write.data, SetOptions(merge: true));
        } else {
          await collection.add(write.data);
        }
        break;
      case PendingWriteOp.delete:
        if (write.docId != null) {
          await collection.doc(write.docId).delete();
        }
        break;
    }
  };

  runApp(const BassTrainingApp());
}

class BassTrainingApp extends StatelessWidget {
  const BassTrainingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProgrammeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => SkiHoursProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => BrandingProvider()),
      ],
      child: const _ThemedApp(),
    );
  }
}

/// Loads the org's white-label branding (once a user is authenticated)
/// and rebuilds MaterialApp's theme from it — the runtime half of the
/// white-label architecture requirement (config in Firestore, not code).
class _ThemedApp extends StatelessWidget {
  const _ThemedApp();

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, BrandingProvider>(
      builder: (context, auth, branding, _) {
        final orgId =
            auth.currentUser?.organisationId ?? AppConstants.demoOrganisationId;
        if (auth.isAuthenticated &&
            branding.branding == null &&
            !branding.isLoading) {
          // Fire-and-forget load; UI rebuilds via notifyListeners when done.
          Future.microtask(() => branding.load(orgId));
        }
        return MaterialApp(
          title: branding.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(
            primaryOverride:
                auth.isAuthenticated ? branding.primaryColor : null,
            accentOverride: auth.isAuthenticated ? branding.accentColor : null,
          ),
          home: const AppRoot(),
        );
      },
    );
  }
}

/// Root widget: shows splash while resolving auth state, then routes to
/// the correct role dashboard, or login if unauthenticated.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // if (!auth.isAuthenticated) {
        //   return const LoginScreen();
        // }
        if (auth.isLoading) {
          return const SplashScreen();
        }

        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }
        switch (auth.role) {
          case UserRole.superAdmin:
            return const SuperAdminDashboard();
          case UserRole.headCoach:
            return const HeadCoachDashboard();
          case UserRole.coach:
            return const CoachDashboard();
          case UserRole.trainee:
          default:
            return const TraineeDashboard();
        }
      },
    );
  }
}

/// Exported for use as the initial route while Firebase/auth resolves.
class AppSplash extends StatelessWidget {
  const AppSplash({super.key});
  @override
  Widget build(BuildContext context) => const SplashScreen();
}
