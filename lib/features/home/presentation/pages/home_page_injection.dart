import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../data/datasources/firebase_data_source.dart';
import '../bloc/home_bloc.dart';

class HomePageInjection {
  static HomeBloc createHomeBloc() {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    final dataSource = FirebaseDataSourceImpl(
      firestore: firestore,
      userId: auth.currentUser?.uid ?? '',
    );

    final repository = HomeRepositoryImpl(dataSource: dataSource, auth: auth);

    return HomeBloc(homeRepository: repository);
  }
}
