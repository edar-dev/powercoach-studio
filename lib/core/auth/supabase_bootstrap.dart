import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBootstrap {
  SupabaseBootstrap._();

  static String _url = '';
  static String _anonKey = '';
  static bool _initialized = false;
  static Future<void>? _initFuture;

  static final ValueNotifier<int> refreshTick = ValueNotifier<int>(0);

  static bool get isInitialized => _initialized;

  static void configure({
    required String url,
    required String anonKey,
  }) {
    _url = url.trim();
    _anonKey = anonKey.trim();
  }

  static Future<void> ensureInitialized() {
    if (_initialized) return Future<void>.value();
    if (_initFuture != null) return _initFuture!;
    if (_url.isEmpty || _anonKey.isEmpty) return Future<void>.value();

    _initFuture = _initializeInternal();
    return _initFuture!;
  }

  static Future<void> _initializeInternal() async {
    try {
      await Supabase.initialize(url: _url, anonKey: _anonKey);
      _initialized = true;
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('already initialized')) {
        _initialized = true;
      } else {
        rethrow;
      }
    } finally {
      refreshTick.value++;
    }
  }

  static User? get currentUser {
    if (!_initialized) return null;
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }
}
