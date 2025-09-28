/*
// lib/services/secure_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart'; // Required for the 'kIsWeb' check
/// 🛡️ This service handles screen security features like preventing screenshots.
/// It is platform-aware and will only run on supported mobile platforms.
class SecureService {
  /// Applies screenshot and screen recording protection on mobile platforms.
  /// On web, this method does nothing.
  static Future<void> secureScreen() async {
    // This check ensures the secure screen code only runs on mobile (Android/iOS)
    // and is completely ignored on the web.
    if (!kIsWeb) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  /// Removes screenshot and screen recording protection on mobile platforms.
  /// On web, this method does nothing.
  static Future<void> unsecureScreen() async {
    if (!kIsWeb) {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }
}*/
