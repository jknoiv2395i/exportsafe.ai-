import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'presentation/providers/audit_provider.dart';
// import 'firebase_options.dart'; // TODO: Add firebase_options.dart after configuring Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Firebase.initializeApp(); // Make sure to configure Firebase for your platform
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => AuditProvider()),
        // TODO: Add other providers here
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
