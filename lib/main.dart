import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('GROUNDZERO: App starting...');

  // Lock the app to portrait mode to prevent layout breaks on phone rotation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        // Rule 7: Clamp system text scale between 0.9 and 1.1 so large system fonts don't break layout
        final clampedTextScaler = mediaQuery.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.1,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedTextScaler),
          // Rule 8: Limit content width on very wide screens (tablets/foldables) using ConstrainedBox with maxWidth around 500 and Center
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
