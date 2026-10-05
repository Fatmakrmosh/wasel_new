import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient? get client {
    if (!SupabaseConfig.isConfigured) {
      return null;
    }

    return Supabase.instance.client;
  }

  static bool get isReady {
    return SupabaseConfig.isConfigured;
  }
}