import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/startup_error_app.dart';
import 'core/config/backend_config.dart';
import 'core/firebase/firebase_initializer.dart';
import 'core/logging/app_logger.dart';
import 'core/supabase/supabase_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const logger = AppLogger(component: 'startup');
  final backendConfig = BackendConfig.fromEnvironment();
  logger.info(
    'app_startup',
    message: 'Application startup started.',
    details: {
      'use_supabase_backend': backendConfig.useSupabaseBackend,
      'use_firebase_backend': backendConfig.useFirebaseBackend,
    },
  );
  try {
    await initializeSupabaseApp(backendConfig);
    if (backendConfig.useFirebaseBackend) {
      await initializeFirebaseApp();
    }
  } on BackendConfigException catch (error) {
    logger.error(
      'app_startup_failed',
      message: 'Application startup failed because backend config is invalid.',
      details: {
        'error_type': error.runtimeType.toString(),
      },
    );
    runApp(StartupErrorApp(message: error.message));
    return;
  }

  logger.info(
    'app_startup_completed',
    message: 'Application startup completed.',
  );
  runApp(const ProviderScope(child: PetConnectApp()));
}
