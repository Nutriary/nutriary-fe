import 'package:flutter/material.dart';
import 'package:nutriary_fe/src/core/di/injection.dart';
import 'package:nutriary_fe/src/routing/app_router.dart';
import 'package:nutriary_fe/src/theme/app_theme.dart';
import 'package:nutriary_fe/src/features/notification/notification_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<NotificationService>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    return MaterialApp.router(
      routerConfig: appRouter.router,
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'nutriary_fe',
      onGenerateTitle: (context) => 'Nutriary',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.system,
    );
  }
}
