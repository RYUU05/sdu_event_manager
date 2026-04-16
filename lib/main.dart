import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/providers/language_provider.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc_simple.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

final _router = AppRouter();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => LanguageProvider())],
      child: BlocProvider(
        create: (_) => AuthBloc(AuthRepositoryImpl()),
        child: MaterialApp.router(
          title: 'SDU Events',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          routerConfig: _router.config(),
        ),
      ),
    );
  }
}
