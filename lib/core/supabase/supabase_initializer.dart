import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/backend_config.dart';

Future<void> initializeSupabaseApp(BackendConfig config) async {
  if (!config.useSupabaseBackend) {
    return;
  }

  await Supabase.initialize(
    url: config.supabaseUri.toString(),
    publishableKey: config.requiredSupabaseAnonKey,
  );
}
