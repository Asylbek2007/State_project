import 'package:flutter/foundation.dart' show kIsWeb;

/// API configuration for backend endpoints.
///
/// ⚠️ ВАЖНО:
/// - Для веб-версии нужен публичный URL backend (не локальный IP!)
/// - Для мобильных (iOS/Android) можно использовать локальный IP
///
/// Как найти IP адрес на Mac:
/// 1. Откройте Terminal
/// 2. Выполните: `ipconfig getifaddr en0` (для Wi-Fi)
///    или `ipconfig getifaddr en1` (для Ethernet)
///
class ApiConfig {
  /// Base URL for backend API.
  /// 
  /// Автоматически определяет платформу:
  /// - Web: использует публичный URL (нужно задеплоить backend!)
  /// - Mobile: использует локальный IP для разработки
  /// 
  /// ⚠️ ДЛЯ ВЕБ-ВЕРСИИ:
  /// Нужно задеплоить backend на публичный хостинг (Railway, Render, Cloud Run)
  /// и заменить URL ниже на ваш публичный адрес.
  /// 
  /// Пример для задеплоенного backend:
  /// static const String _webBaseUrl = 'https://your-backend.railway.app/api';
  /// 
  /// Текущий локальный IP: 172.20.10.6
  /// Если IP изменился, найдите новый: `ipconfig getifaddr en0`
  static String get baseUrl {
    if (kIsWeb) {
      // ⚠️ ВАЖНО: Для веб-версии нужен публичный URL backend!
      // Локальный IP (172.20.10.6) не работает из интернета.
      // 
      // ВАРИАНТЫ РЕШЕНИЯ:
      // 1. Задеплойте backend на Railway: https://railway.app
      //    После деплоя замените URL ниже на ваш Railway URL
      //    Пример: 'https://your-backend.railway.app/api'
      //
      // 2. Используйте ngrok для временного туннеля:
      //    ngrok http 8080
      //    Затем замените URL на ngrok URL
      //
      // 3. Задеплойте на Render.com или Google Cloud Run
      //
      // ВРЕМЕННО: используем localhost (не будет работать из интернета!)
      // TODO: Замените на публичный URL после деплоя backend
      return 'http://localhost:8080/api';
    } else {
      // Для мобильных платформ (iOS/Android) используем локальный IP
      return 'http://172.20.10.6:8080/api';
    }
  }
  
  /// Full URL for auth endpoints.
  static String get authBaseUrl => '$baseUrl/auth';
  
  /// Full URL for user endpoints.
  static String get userBaseUrl => '$baseUrl/user';
  
  /// Full URL for donations endpoints.
  static String get donationsBaseUrl => '$baseUrl/donations';
  
  /// Full URL for goals endpoints.
  static String get goalsBaseUrl => '$baseUrl/goals';
  
  /// Full URL for admin endpoints.
  static String get adminBaseUrl => '$baseUrl/admin';
  
  /// Timeout duration for API requests (in seconds).
  static const int requestTimeoutSeconds = 30;
}

