class SupabaseConfig {
  static const String url =
      'https://nxmsfpccezuhvhsfwipd.supabase.co';

  // Keep the publishable key out of the repository.
  // Pass it at build/run time with:
  // --dart-define=SUPABASE_PUBLISHABLE_KEY=...
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static bool get isConfigured {
    return url.isNotEmpty && publishableKey.isNotEmpty;
  }
}
