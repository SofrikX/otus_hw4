import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/backend_config.dart';
import 'core/firebase/firebase_initializer.dart';
import 'core/supabase/supabase_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final backendConfig = BackendConfig.fromEnvironment();
  await initializeSupabaseApp(backendConfig);
  if (backendConfig.useFirebaseBackend) {
    await initializeFirebaseApp();
  }
  runApp(const ProviderScope(child: PetConnectApp()));
}
