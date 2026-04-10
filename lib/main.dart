// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sijual_app/features/auth/presentation/auth_controller.dart';
import 'config/router/app_router.dart';
import 'config/theme/app_theme.dart';

// lib/main.dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final container = ProviderContainer();
  
  // PAKSA baca user dari local storage SEBELUM aplikasi muncul di layar
  // Ini kunci agar status "isLoggedIn" langsung siap sejak detik pertama
  await container.read(authControllerProvider.notifier).build();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'SiJual 2.0',
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration
      theme: AppTheme.lightTheme,
      
      // Router Configuration
      routerConfig: router,
    );
  }
}