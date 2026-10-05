import 'package:flutter/material.dart';
import 'app/router/app_router.dart';
import 'core/theme/app_theme.dart';

class WaselApp extends StatelessWidget {
  const WaselApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'WASEL',
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
