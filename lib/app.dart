import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/localization/app_locale.dart';

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
          localizationsDelegates: const [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          routerConfig: appRouter,
        );
      },
    );
  }
}