import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:event_manager/features/home/domain/entities/event.dart';
import 'package:event_manager/features/home/domain/entities/club.dart';
import 'package:event_manager/features/home/domain/usecases/get_upcoming_events.dart';
import 'package:event_manager/features/home/domain/usecases/get_popular_clubs.dart';
import 'package:event_manager/features/home/domain/usecases/register_for_event.dart'
    as usecases;
import 'package:event_manager/features/home/domain/repositories/home_repository.dart';
import 'package:event_manager/features/home/data/repositories/home_repository_impl.dart';
import 'package:event_manager/features/home/data/datasources/firebase_data_source.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/event_card.dart';
import '../widgets/club_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

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
    final registerForEvent = usecases.RegisterForEvent(repository);

    return HomeBloc(
      getUpcomingEvents: getUpcomingEvents,
      getPopularClubs: getPopularClubs,
      registerForEvent: registerForEvent,
      homeRepository: repository,
    );
  }
}
