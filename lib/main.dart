import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/storage/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage and seed initial demo data
  await LocalStorageService.instance.init();

  runApp(
    const ProviderScope(
      child: GroundZeroApp(),
    ),
  );
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
