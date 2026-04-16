import 'package:cloud_firestore/cloud_firestore.dart';
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
  Stream<QuerySnapshot>? eventsStream;

  @override
  void initState() {
    super.initState();
    homeBloc = HomePageInjection.createHomeBloc();
    homeBloc.add(LoadHomeData());
    eventsStream = FirebaseFirestore.instance.collection('events').snapshots();
  }

  @override
  void dispose() {
    homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => homeBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SDU Events'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated &&
                authState.user.role == UserRole.club) {
              return FloatingActionButton.extended(
                onPressed: () => context.router.push(const CreateEventRoute()),
                icon: const Icon(Icons.add),
                label: const Text('Create Event'),
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
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is HomeLoaded || state is HomeRefreshing) {
              final clubs = state is HomeLoaded
                  ? state.popularClubs
                  : (state as HomeRefreshing).popularClubs;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Events from Firestore
                    StreamBuilder<QuerySnapshot>(
                      stream: eventsStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No events yet'),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Upcoming Events',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 300,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final data =
                                      docs[index].data()
                                          as Map<String, dynamic>;
                                  return SizedBox(
                                    width: 350,
                                    child: Card(
                                      margin: const EdgeInsets.all(8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data['title'] ?? 'No title',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(data['category'] ?? ''),
                                            const SizedBox(height: 8),
                                            Text(data['location'] ?? ''),
                                            const Spacer(),
                                            Text(
                                              data['dateTime'] != null
                                                  ? (data['dateTime']
                                                            as Timestamp)
                                                        .toDate()
                                                        .toString()
                                                        .substring(0, 16)
                                                  : '',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    // Clubs
                    if (clubs.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Popular Clubs',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: clubs.length,
                          itemBuilder: (context, index) {
                            return ClubCard(club: clubs[index], onTap: () {});
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
