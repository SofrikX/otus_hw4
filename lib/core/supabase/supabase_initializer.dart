import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/backend_config.dart';
import '../logging/app_logger.dart';

Future<void> initializeSupabaseApp(BackendConfig config) async {
  const logger = AppLogger(component: 'supabase');
  if (!config.useSupabaseBackend) {
    logger.info(
      'supabase_initialization_skipped',
      message: 'Supabase backend is disabled.',
    );
    return;
  }

  logger.info(
    'supabase_initialization_started',
    message: 'Supabase initialization started.',
  );
  await Supabase.initialize(
    url: config.supabaseUri.toString(),
    publishableKey: config.requiredSupabasePublishableKey,
  );
  logger.info(
    'supabase_initialization_completed',
    message: 'Supabase initialization completed.',
  );
}
