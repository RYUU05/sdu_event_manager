import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/get_upcoming_events.dart';
import '../../domain/usecases/get_popular_clubs.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../data/datasources/firebase_data_source.dart';
import '../bloc/home_bloc.dart';

class HomePageInjection {
  static HomeBloc createHomeBloc() {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final userId = auth.currentUser?.uid ?? '';

    final dataSource = FirebaseDataSourceImpl(
      firestore: firestore,
      userId: userId,
    );

    final repository = HomeRepositoryImpl(dataSource: dataSource, auth: auth);

    final getUpcomingEvents = GetUpcomingEvents(repository);
    final getPopularClubs = GetPopularClubs(repository);

    return HomeBloc(
      getUpcomingEvents: getUpcomingEvents,
      getPopularClubs: getPopularClubs,
      homeRepository: repository,
    );
  }
}
