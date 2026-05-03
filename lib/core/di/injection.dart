import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/applications/data/application_repository_impl.dart';
import '../../features/applications/domain/repositories/application_repository.dart';
import '../../features/applications/presentation/bloc/admin_application_bloc.dart';
import '../../features/applications/presentation/bloc/club_application_bloc.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc_simple.dart';
import '../../features/home/data/datasources/firebase_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/my_events/presentation/bloc/my_events_bloc.dart';
import '../../features/settings/data/datasources/settings_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/unibuddy/data/unibuddy_api.dart';

final getIt = GetIt.instance;
final sl = getIt;

void configureDependencies() {
  getIt.registerLazySingleton(() => UniBuddyApi());

  // 1. Firebase Instances
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);

  // 2. Data Sources
  getIt.registerLazySingleton<FirebaseDataSource>(() => FirebaseDataSourceImpl(
        firestore: getIt<FirebaseFirestore>(),
        userId: getIt<FirebaseAuth>().currentUser?.uid ?? '',
      ));

  getIt.registerLazySingleton<SettingsDataSource>(() => SettingsDataSource());

  // 3. Repositories
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
            auth: getIt<FirebaseAuth>(),
            db: getIt<FirebaseFirestore>(),
          ));

  getIt.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(
        dataSource: getIt<FirebaseDataSource>(),
        auth: getIt<FirebaseAuth>(),
      ));

  getIt.registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(getIt<SettingsDataSource>()));

  // Репозиторий заявок на клубы
  getIt.registerLazySingleton<ApplicationRepository>(
      () => ApplicationRepositoryImpl(db: getIt<FirebaseFirestore>()));

  // 4. BLoCs
  // AuthBloc — синглтон, живёт всё время работы приложения
  getIt.registerLazySingleton(() => AuthBloc(getIt<AuthRepository>()));

  // Feature BLoCs — фабрика (пересоздаётся при каждом открытии экрана)
  getIt.registerFactory(() => HomeBloc(homeRepository: getIt<HomeRepository>()));
  getIt.registerFactory(() => MyEventsBloc(getIt<HomeRepository>()));
  getIt.registerFactory(
      () => SettingsBloc(getIt<SettingsRepository>(), getIt<AuthBloc>()));

  // BLoC-и для заявок
  getIt.registerFactory(
      () => ClubApplicationBloc(getIt<ApplicationRepository>()));
  getIt.registerFactory(
      () => AdminApplicationBloc(getIt<ApplicationRepository>()));
}
