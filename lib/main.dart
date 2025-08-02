import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/theme/app_theme.dart';

import 'core/services/permission_service.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize permissions
  try {
    await PermissionService.requestPermissions();
  } catch (e, s) {
    await Sentry.captureException(e, stackTrace: s);
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await SentryFlutter.init((options) {
    options.dsn = const String.fromEnvironment('SENTRY_DSN');
    // Reduce performance monitoring for better app performance
    options.tracesSampleRate = 0.1; // Only 10% of transactions
    options.profilesSampleRate = 0.1; // Only 10% of profiles
    options.debug = false; // Disable debug mode
  }, appRunner: () => runApp(const ProviderScope(child: MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        375,
        812,
      ), // iPhone 12 Pro dimensions as design reference
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            // Adaptive system UI overlay style
            final brightness = MediaQuery.of(context).platformBrightness;
            SystemChrome.setSystemUIOverlayStyle(
              brightness == Brightness.dark
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
            );
            // Use dynamic color scheme if available, otherwise fallback to our app theme
            return MaterialApp.router(
              title: 'PDF Scanner Pro',
              debugShowCheckedModeBanner: false,
              theme:
                  lightDynamic != null
                      ? ThemeData(
                        useMaterial3: true,
                        colorScheme: lightDynamic,
                        brightness: Brightness.light,
                      )
                      : AppTheme.lightTheme,
              darkTheme:
                  darkDynamic != null
                      ? ThemeData(
                        useMaterial3: true,
                        colorScheme: darkDynamic,
                        brightness: Brightness.dark,
                      )
                      : AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              routerConfig: AppRouter.config(),
            );
          },
        );
      },
    );
  }
}
