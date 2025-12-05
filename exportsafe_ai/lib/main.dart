import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/audit_provider.dart';
// import 'firebase_options.dart'; // TODO: Add firebase_options.dart after configuring Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    if (kIsWeb) {
      // For Web, we need options. If not provided, we skip or use dummy.
      // Since we don't have options yet, we'll skip Firebase init for UI demo
      print("Firebase init skipped on Web (missing config)");
    } else {
      await Firebase.initializeApp(); 
    }
  } catch (e) {
    print("Firebase init failed: $e");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AuditProvider()),
      ],
      child: MaterialApp.router(
        title: 'ExportSafe AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
      ),
    );
  }
}
