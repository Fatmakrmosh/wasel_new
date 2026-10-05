class SupabaseConfig {
  static const String url =
      'https://nxmsfpccezuhvhsfwipd.supabase.co';

  static const String publishableKey =
      'YOUR_PUBLISHABLE_KEY';

  static bool get isConfigured {
    return url.isNotEmpty &&
        publishableKey.isNotEmpty &&
        publishableKey != 'YOUR_PUBLISHABLE_KEY';
  }
}