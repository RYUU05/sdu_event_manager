import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import '../../../../core/router/app_router.gr.dart';
import '../../../auth/presentation/bloc/auth_bloc_simple.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/club_card.dart';
import 'home_page_injection.dart';

@RoutePage(name: 'HomeRoute')
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeBloc homeBloc;

  @override
  void initState() {
    super.initState();
    homeBloc = HomePageInjection.createHomeBloc();
    homeBloc.add(LoadHomeData());
  }

  @override
  void dispose() {
    homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => homeBloc,
      child: Scaffold(
        appBar: AppBar(title: Text(context.localization.appTitle)),

        floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated &&
                authState.user.role == UserRole.club) {
              return FloatingActionButton.extended(
                onPressed: () => context.router.push(const CreateEventRoute()),
                icon: const Icon(Icons.add),
                label: Text(context.localization.create_event),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeError) {
              return Center(child: Text(state.message));
            }

            if (state is HomeLoaded) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        context.localization.comingEvents,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      ...docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => context.router.push(
                              EventDetailRoute(eventId: doc.id),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['title'] ?? 'No title',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(data['category'] ?? ''),
                                  Text(data['location'] ?? ''),
                                  const SizedBox(height: 6),
                                  Text(
                                    data['dateTime'] != null
                                        ? (data['dateTime'] as Timestamp)
                                              .toDate()
                                              .toString()
                                              .substring(0, 16)
                                        : '',
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Подробнее →',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      if (state.popularClubs.isNotEmpty) ...[
                        const Text(
                          'Popular Clubs',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        ...state.popularClubs.map(
                          (club) => ClubCard(club: club, onTap: () {}),
                        ),
                      ],
                    ],
                  );
                },
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
