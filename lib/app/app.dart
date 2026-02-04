import 'package:flutter/material.dart';
import 'theme.dart';
import 'routes.dart';
import 'constants.dart';
import '../core/widgets/auth_wrapper.dart';

class WamoApp extends StatelessWidget {
  const WamoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
