import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/startup_error_app.dart';
import 'core/config/backend_config.dart';
import 'core/firebase/firebase_initializer.dart';
import 'core/supabase/supabase_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final backendConfig = BackendConfig.fromEnvironment();
  try {
    await initializeSupabaseApp(backendConfig);
    if (backendConfig.useFirebaseBackend) {
      await initializeFirebaseApp();
    }
  } on BackendConfigException catch (error) {
    runApp(StartupErrorApp(message: error.message));
    return;
  }

  runApp(const ProviderScope(child: PetConnectApp()));
}
