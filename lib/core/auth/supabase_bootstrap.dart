import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBootstrap {
  SupabaseBootstrap._();

  static String _url = '';
  static String _anonKey = '';
  static bool _initialized = false;
  static bool _authReady = false;
  static Future<void>? _initFuture;
  static StreamSubscription<AuthState>? _authSubscription;

  static final ValueNotifier<int> refreshTick = ValueNotifier<int>(0);

  static bool get isInitialized => _initialized;

  /// True once auth state is safe to read for routing (session restored or unavailable).
  static bool get authReady => _authReady;

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
    if (_url.isEmpty || _anonKey.isEmpty) {
      markAuthReadyWithoutSupabase();
      return Future<void>.value();
    }

    _initFuture = _initializeInternal();
    return _initFuture!;
  }

  static void markAuthReadyWithoutSupabase() {
    _authReady = true;
    refreshTick.value++;
  }

  static Future<void> _initializeInternal() async {
    try {
      await Supabase.initialize(url: _url, anonKey: _anonKey);
      _initialized = true;
      _bindAuthStateListener();
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('already initialized')) {
        _initialized = true;
        _bindAuthStateListener();
      } else {
        rethrow;
      }
    } finally {
      _authReady = true;
      refreshTick.value++;
    }
  }

  static void _bindAuthStateListener() {
    if (_authSubscription != null) return;
    try {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
        (_) {
          refreshTick.value++;
        },
      );
    } catch (_) {
      // Ignore when auth client is unavailable.
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
