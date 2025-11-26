import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'config/app_config.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/registration_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/health_profile_provider.dart';
import 'providers/doctor_search_provider.dart';
import 'providers/appointment_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/verification_service.dart';
import 'services/health_profile_service.dart';
import 'services/doctor_service.dart';
import 'services/appointment_service.dart';
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
        
        // Auth services
        ProxyProvider<ApiService, AuthService>(
          update: (_, apiService, __) => AuthService(apiService),
        ),
        ProxyProvider<ApiService, VerificationService>(
          update: (_, apiService, __) => VerificationService(apiService),
        ),
        ProxyProvider<ApiService, HealthProfileService>(
          update: (_, apiService, __) => HealthProfileService(),
        ),
        ProxyProvider<ApiService, DoctorService>(
          update: (_, apiService, __) => DoctorService(apiService),
        ),
        ProxyProvider<ApiService, AppointmentService>(
          update: (_, apiService, __) => AppointmentService(apiService),
        ),
        
        // State providers
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(),
        ),
        ChangeNotifierProxyProvider3<AuthService, StorageService, ApiService, AuthProvider>(
          create: (context) => AuthProvider(
            authService: context.read<AuthService>(),
            storageService: context.read<StorageService>(),
            apiService: context.read<ApiService>(),
          ),
          update: (_, authService, storageService, apiService, previous) =>
              previous ?? AuthProvider(
                authService: authService,
                storageService: storageService,
                apiService: apiService,
              ),
        ),
        ChangeNotifierProxyProvider3<AuthService, VerificationService, AuthProvider, RegistrationProvider>(
          create: (context) {
            final provider = RegistrationProvider(
              context.read<AuthService>(),
              context.read<VerificationService>(),
            );
            provider.setAuthProvider(context.read<AuthProvider>());
            return provider;
          },
          update: (_, authService, verificationService, authProvider, previous) {
            if (previous != null) {
              previous.setAuthProvider(authProvider);
              return previous;
            }
            final provider = RegistrationProvider(authService, verificationService);
            provider.setAuthProvider(authProvider);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider2<HealthProfileService, StorageService, HealthProfileProvider>(
          create: (context) => HealthProfileProvider(
            healthProfileService: context.read<HealthProfileService>(),
            storageService: context.read<StorageService>(),
          ),
          update: (_, healthProfileService, storageService, previous) =>
              previous ?? HealthProfileProvider(
                healthProfileService: healthProfileService,
                storageService: storageService,
              ),
        ),
        ChangeNotifierProxyProvider2<DoctorService, StorageService, DoctorSearchProvider>(
          create: (context) => DoctorSearchProvider(
            doctorService: context.read<DoctorService>(),
            storageService: context.read<StorageService>(),
          ),
          update: (_, doctorService, storageService, previous) =>
              previous ?? DoctorSearchProvider(
                doctorService: doctorService,
                storageService: storageService,
              ),
        ),
        ChangeNotifierProxyProvider2<AppointmentService, StorageService, AppointmentProvider>(
          create: (context) => AppointmentProvider(
            appointmentService: context.read<AppointmentService>(),
            storageService: context.read<StorageService>(),
          ),
          update: (_, appointmentService, storageService, previous) =>
              previous ?? AppointmentProvider(
                appointmentService: appointmentService,
                storageService: storageService,
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
              Locale('en'), // English
              Locale('ar'), // Arabic
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
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
