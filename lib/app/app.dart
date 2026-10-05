import 'package:flutter/material.dart';
import '../core/localization/app_locale.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class WaselApp extends StatelessWidget {
  const WaselApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocale.locale,
      builder: (context, locale, _) {
        return MaterialApp.router(
          title: 'WASEL',
          debugShowCheckedModeBanner: false,
          theme: WaselTheme.darkTheme,
          locale: locale,
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
          ],
          routerConfig: appRouter,
        );
      },
    );
  }
}