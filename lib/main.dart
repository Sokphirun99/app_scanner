import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'features/scanner/presentation/scanner_home_page.dart';

Future<void> main() async {
  await SentryFlutter.init((options) {
    options.dsn =
        'https://1b45803ca28e2a641c47f6679ee7edaa@o4509645142425600.ingest.us.sentry.io/4509645143801856';
    options.tracesSampleRate = 1.0;
    options.profilesSampleRate = 1.0;
  }, appRunner: () => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Scanner App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const ScannerHomePage(),
    );
  }
}
