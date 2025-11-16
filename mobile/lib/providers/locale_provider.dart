import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Locale provider for managing app localization state
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  
  Locale _locale = const Locale('en', 'US');
  
  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  String? get countryCode => _locale.countryCode;
  
  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English (US)
    Locale('ar', 'SA'), // Arabic (Saudi Arabia)
  ];
  
  /// Initialize locale from storage
  Future<void> initialize() async {
    try {
      final StorageService storageService = StorageService();
      final savedLocale = await storageService.getValue(_localeKey);
      
      if (savedLocale != null) {
        final Map<String, dynamic> localeMap = savedLocale as Map<String, dynamic>;
        final languageCode = localeMap['languageCode'] as String;
        final countryCode = localeMap['countryCode'] as String?;
        
        final newLocale = Locale(languageCode, countryCode);
        if (supportedLocales.contains(newLocale)) {
          _locale = newLocale;
          notifyListeners();
        }
      }
    } catch (e) {
      // If there's an error loading the locale, use default
      _locale = const Locale('en', 'US');
    }
  }
  
  /// Set locale
  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    
    if (!supportedLocales.contains(newLocale)) {
      throw ArgumentError('Unsupported locale: $newLocale');
    }
    
    _locale = newLocale;
    notifyListeners();
    
    try {
      final StorageService storageService = StorageService();
      await storageService.setValue(_localeKey, {
        'languageCode': newLocale.languageCode,
        'countryCode': newLocale.countryCode,
      });
    } catch (e) {
      // Handle storage error silently
      debugPrint('Failed to save locale preference: $e');
    }
  }
  
  /// Set English locale
  Future<void> setEnglish() async {
    await setLocale(const Locale('en', 'US'));
  }
  
  /// Set Arabic locale
  Future<void> setArabic() async {
    await setLocale(const Locale('ar', 'SA'));
  }
  
  /// Toggle between English and Arabic
  Future<void> toggleLanguage() async {
    if (_locale.languageCode == 'en') {
      await setArabic();
    } else {
      await setEnglish();
    }
  }
  
  /// Check if current locale is RTL (Right-to-Left)
  bool get isRTL => _locale.languageCode == 'ar';
  
  /// Check if current locale is English
  bool get isEnglish => _locale.languageCode == 'en';
  
  /// Check if current locale is Arabic
  bool get isArabic => _locale.languageCode == 'ar';
  
  /// Get locale display name
  String getDisplayName() {
    switch (_locale.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      default:
        return _locale.languageCode;
    }
  }
  
  /// Get text direction based on current locale
  TextDirection get textDirection {
    return isRTL ? TextDirection.rtl : TextDirection.ltr;
  }
  
  /// Get locale from system
  static Locale? getSystemLocale() {
    final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
    
    for (final systemLocale in systemLocales) {
      for (final supportedLocale in supportedLocales) {
        if (systemLocale.languageCode == supportedLocale.languageCode) {
          return supportedLocale;
        }
      }
    }
    
    return null;
  }
  
  /// Set locale to system default if supported
  Future<void> setSystemLocale() async {
    final systemLocale = getSystemLocale();
    if (systemLocale != null) {
      await setLocale(systemLocale);
    }
  }
}
