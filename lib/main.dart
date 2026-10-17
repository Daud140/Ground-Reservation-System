import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('GROUNDZERO: App starting...');

  // Initialize Hive storage and seed initial demo data safely
  try {
    await LocalStorageService.instance.init();
    debugPrint('GROUNDZERO: Local storage initialized');
  } catch (e, st) {
    debugPrint('GROUNDZERO: Storage init fallback: $e\n$st');
  }

  runApp(const ProviderScope(child: GroundZeroApp()));
  debugPrint('GROUNDZERO: runApp called');
}

class GroundZeroApp extends ConsumerWidget {
  const GroundZeroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'GroundZero',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
