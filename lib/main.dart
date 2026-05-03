import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'core/di/injection.dart';
import 'core/providers/language_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/in_app_notification_service.dart';
import 'features/auth/presentation/bloc/auth_bloc_simple.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  configureDependencies();
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

final _router = AppRouter();

// Используем navigatorKey из сервиса уведомлений —
// это позволяет показывать Dialog без BuildContext

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LanguageProvider()..init(),
        ),
      ],
      child: BlocProvider.value(
        value: getIt<AuthBloc>(),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            // Запускаем/останавливаем слушатель уведомлений при смене auth-состояния
            if (state is Authenticated) {
              InAppNotificationService.instance.init(state.user.id);
            } else if (state is Unauthenticated) {
              InAppNotificationService.instance.dispose();
            }
          },
          child: Consumer<LanguageProvider>(
            builder: (context, languageProvider, _) {
              return MaterialApp.router(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: languageProvider.locale,
                title: 'SDU Events',
                debugShowCheckedModeBanner: false,
                // Передаём navigatorKey для показа диалогов через сервис
                routerConfig: _router.config(
                  navigatorObservers: () => [],
                ),
                theme: ThemeData(
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  useMaterial3: true,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
