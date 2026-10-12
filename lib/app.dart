import 'package:flutter/material.dart';
import 'core/router.dart';
import 'core/theme.dart';

class StashlyApp extends StatelessWidget {
  const StashlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Stashly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
