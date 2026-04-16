import 'package:event_manager/core/router/app_router.dart';
import 'package:event_manager/core/providers/language_provider.dart';
import 'package:event_manager/features/auth/presentation/bloc/auth_bloc_simple.dart';
import 'package:event_manager/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:event_manager/firebase_options.dart';
import 'package:event_manager/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

final _router = AppRouter();

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(AuthRepositoryImpl(FirebaseAuth.instance)),
        ),
      ],
      child: ChangeNotifierProvider(
        create: (_) => LanguageProvider()..init(),
        child: Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            return MaterialApp.router(
              title: 'Sdu Event Manager',
              theme: ThemeData(primarySwatch: Colors.blue),
              debugShowCheckedModeBanner: false,
              routerConfig: _router.config(),
              locale: languageProvider.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      ),
    );
  }
}
