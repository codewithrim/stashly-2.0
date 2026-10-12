import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/auth_screen.dart';
import '../features/detail/detail_screen.dart';
import '../features/editor/editor_screen.dart';
import '../features/inbox/inbox_screen.dart';
import '../features/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggingIn = state.matchedLocation == '/auth';

    if (session == null && !isLoggingIn) {
      return '/auth';
    }
    if (session != null && isLoggingIn) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const InboxScreen(),
    ),
    GoRoute(
      path: '/item/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailScreen(itemId: id);
      },
    ),
    GoRoute(
      path: '/editor/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return EditorScreen(itemId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Not Found')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Page not found'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go('/'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
