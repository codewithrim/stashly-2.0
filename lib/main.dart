import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/config.dart';
import 'core/router.dart';
import 'data/services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // Initialize notifications with tap-to-open routing
  await ReminderService.instance.initialize(
    onSelectNotification: (itemId) {
      if (itemId != null && itemId.isNotEmpty) {
        appRouter.push('/item/$itemId');
      }
    },
  );

  runApp(
    const ProviderScope(
      child: StashlyApp(),
    ),
  );
}
