/// Application configuration constants supplied via --dart-define.
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://iodqhxejlviovoaivnke.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_Y4JMsINnkWaE9JLIi9vqQw_q_ON8E36',
  );
}
