import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: EcoTrackApp(),
    ),
  );
}

class EcoTrackApp extends ConsumerWidget {
  const EcoTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'EcoTrack Smart Waste',
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.darkTheme, // Force dark mode aesthetic as per PRD
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
