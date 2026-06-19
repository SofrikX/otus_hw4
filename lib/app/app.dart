import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/analytics/analytics_event.dart';
import '../core/analytics/analytics_service.dart';
import 'router.dart';
import 'theme.dart';

class PetConnectApp extends ConsumerStatefulWidget {
  const PetConnectApp({super.key});

  @override
  ConsumerState<PetConnectApp> createState() => _PetConnectAppState();
}

class _PetConnectAppState extends ConsumerState<PetConnectApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(analyticsServiceProvider).track(AnalyticsEvent.appOpen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'PetConnect',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      routerConfig: router,
    );
  }
}
