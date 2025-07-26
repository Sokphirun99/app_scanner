import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'features/scanner/presentation/scanner_home_page.dart';
import 'features/scanner/presentation/bloc/scanner_bloc.dart';
import 'features/scanner/data/repositories/scanner_repository_impl.dart';
import 'features/scanner/domain/usecases/scan_document_usecase.dart';
import 'features/pdf_generator/data/repositories/pdf_repository_impl.dart';
import 'features/pdf_generator/domain/usecases/pdf_usecases.dart';
import 'core/services/permission_service.dart';
=======
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_page.dart';
>>>>>>> fix-error

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
<<<<<<< HEAD
  // Initialize permissions
  await PermissionService.requestPermissions();
=======
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
>>>>>>> fix-error
  
  await SentryFlutter.init((options) {
    options.dsn =
        'https://1b45803ca28e2a641c47f6679ee7edaa@o4509645142425600.ingest.us.sentry.io/4509645143801856';
    options.tracesSampleRate = 1.0;
    options.profilesSampleRate = 1.0;
<<<<<<< HEAD
  }, appRunner: () => runApp(const MyApp()));
=======
  }, appRunner: () => runApp(const ProviderScope(child: MyApp())));
>>>>>>> fix-error
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ScannerBloc(
                scanDocumentUsecase: ScanDocumentUsecase(ScannerRepositoryImpl()),
                generatePdfUsecase: GeneratePdfUsecase(PdfRepositoryImpl()),
                sharePdfUsecase: SharePdfUsecase(PdfRepositoryImpl()),
              ),
            ),
          ],
          child: MaterialApp(
            title: 'PDF Scanner App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.indigo,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.light,
              ),
              appBarTheme: AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                titleTextStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            home: const ScannerHomePage(),
          ),
        );
      },
=======
    return MaterialApp(
      title: 'PDF Tools Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
>>>>>>> fix-error
    );
  }
}
