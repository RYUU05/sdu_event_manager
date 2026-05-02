import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc_simple.dart';
import '../../features/home/data/datasources/firebase_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/my_events/presentation/bloc/my_events_bloc.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // 1. Firebase Instances
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);

  // 2. Data Sources
  getIt.registerLazySingleton<FirebaseDataSource>(() => FirebaseDataSourceImpl(
        firestore: getIt<FirebaseFirestore>(),
        userId: getIt<FirebaseAuth>().currentUser?.uid ?? '',
      ));

  // 3. Repositories
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl());

  getIt.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(
        dataSource: getIt<FirebaseDataSource>(),
        auth: getIt<FirebaseAuth>(),
      ));

  // 4. BLoCs
  // AuthBloc needs to persist throughout the app, so Singleton
  getIt.registerLazySingleton(() => AuthBloc(getIt<AuthRepository>()));

  // Feature BLoCs usually are Factories so they get re-created cleanly
  getIt.registerFactory(() => HomeBloc(homeRepository: getIt<HomeRepository>()));
  getIt.registerFactory(() => MyEventsBloc(getIt<HomeRepository>()));
}
