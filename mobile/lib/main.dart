import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'config/app_config.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'services/navigation_service.dart';
import 'utils/error_handler.dart';
import 'utils/logger.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
    Logger.info('Environment configuration loaded');
  } catch (e) {
    Logger.warning('Failed to load .env file, using default configuration');
  }
  
  // Initialize app configuration
  await AppConfig.initialize();
  
  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    ErrorHandler.logError(details.exception, details.stack);
  };
  
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
  
  Logger.info('App initialization completed');
  
  runApp(const ViatraApp());
}

class ViatraApp extends StatelessWidget {
  const ViatraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core services
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
        Provider<NavigationService>(
          create: (_) => NavigationService(),
        ),
        
        // State providers
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            apiService: context.read<ApiService>(),
            storageService: context.read<StorageService>(),
          ),
        ),
      ],
      child: Consumer3<ThemeProvider, LocaleProvider, AuthProvider>(
        builder: (context, themeProvider, localeProvider, authProvider, _) {
          return MaterialApp.router(
            // App Information
            title: 'Viatra Health',
            debugShowCheckedModeBanner: AppConfig.isDebugMode,
            
            // Theme Configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Localization
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('en', 'US'), // English
              Locale('ar', 'SA'), // Arabic
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            // Navigation
            routerConfig: AppRouter.router,
            
            // Error Handling
            builder: (context, child) {
              ErrorHandler.init(context);
              
              // Handle text scaling
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: MediaQuery.of(context)
                      .textScaleFactor
                      .clamp(0.8, 1.2), // Limit text scaling
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}

/// Global error handler for uncaught exceptions
class GlobalErrorHandler {
  static void handleError(Object error, StackTrace? stackTrace) {
    Logger.error('Uncaught error: $error', stackTrace);
    ErrorHandler.logError(error, stackTrace);
  }
}
