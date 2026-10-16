import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'repositories/app_repository.dart';
import 'providers/app_providers.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appRepository = AppRepository();
  await appRepository.init();

  runApp(
    ProviderScope(
      overrides: [
        appRepositoryProvider.overrideWithValue(appRepository),
      ],
      child: const CodialCoinApp(),
    ),
  );
}

class CodialCoinApp extends ConsumerWidget {
  const CodialCoinApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Codial Coin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
