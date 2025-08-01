import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/modern_home_page.dart';
import 'core/services/permission_service.dart';
import 'features/scanner/presentation/bloc/scanner_bloc.dart';
import 'features/scanner/domain/usecases/scan_document_usecase.dart';
import 'features/pdf_generator/domain/usecases/pdf_usecases.dart';
import 'features/scanner/data/repositories/scanner_repository_impl.dart';
import 'features/pdf_generator/data/repositories/pdf_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize permissions
  await PermissionService.requestPermissions();
  
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
    options.dsn =
        'https://1b45803ca28e2a641c47f6679ee7edaa@o4509645142425600.ingest.us.sentry.io/4509645143801856';
    options.tracesSampleRate = 1.0;
    options.profilesSampleRate = 1.0;
  }, appRunner: () => runApp(const ProviderScope(child: MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scannerRepository = ScannerRepositoryImpl();
    final pdfRepository = PdfRepositoryImpl();
    
    return BlocProvider(
      create: (context) => ScannerBloc(
        scanDocumentUsecase: ScanDocumentUsecase(scannerRepository),
        generatePdfUsecase: GeneratePdfUsecase(pdfRepository),
        sharePdfUsecase: SharePdfUsecase(pdfRepository),
      ),
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // iPhone 12 Pro dimensions as design reference
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'PDF Scanner Pro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const ModernHomePage(),
          );
        },
      ),
    );
  }
}
