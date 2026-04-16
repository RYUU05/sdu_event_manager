import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/core/extensions/context_extensions.dart';
import 'package:event_manager/core/router/app_router.gr.dart';
import 'package:event_manager/features/auth/presentation/bloc/auth_bloc_simple.dart';
import 'package:event_manager/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:auto_route/auto_route.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/club_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'home_page_injection.dart';

@RoutePage(name: 'HomeRoute')
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeBloc homeBloc;
  Stream<QuerySnapshot>? _eventsStream;

  @override
  void initState() {
    super.initState();
    homeBloc = HomePageInjection.createHomeBloc();
    homeBloc.add(LoadHomeData());

    // Load events from Firestore (without orderBy to avoid index requirement)
    _eventsStream = FirebaseFirestore.instance.collection('events').snapshots();
  }

  @override
  void dispose() {
    homeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final refreshController = RefreshController();

    return BlocProvider(
      create: (context) => homeBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.localization.appTitle),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          elevation: 0,
        ),
        floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated &&
                authState.user.role == UserRole.club) {
              return FloatingActionButton.extended(
                onPressed: () {
                  context.router.push(const CreateEventRoute());
                },
                icon: const Icon(Icons.add),
                label: const Text('Создать ивент'),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        body: BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state is HomeLoaded) {
              refreshController.refreshCompleted();
            } else if (state is HomeError) {
              refreshController.refreshFailed();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const LoadingWidget(message: 'Загрузка данных...');
              }

              if (state is HomeError) {
                return HomeErrorWidget(
                  message: state.message,
                  onRetry: () => context.read<HomeBloc>().add(LoadHomeData()),
                );
              }

              if (state is HomeEmpty) {
                return const HomeEmptyWidget(
                  message: 'Пока нет мероприятий или клубов',
                );
              }

              if (state is HomeLoaded || state is HomeRefreshing) {
                final events = state is HomeLoaded
                    ? state.upcomingEvents
                    : (state as HomeRefreshing).upcomingEvents;
                final clubs = state.clubs;

                return SmartRefresher(
                  controller: refreshController,
                  onRefresh: () {
                    context.read<HomeBloc>().add(RefreshHomeData());
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Events from Firestore
                        StreamBuilder<QuerySnapshot>(
                          stream: _eventsStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Error loading events: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
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
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    context.localization.comingEvents,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
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
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  data['category'] ?? '',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  data['location'] ?? '',
                                                  style: TextStyle(
                                                    color: Colors.grey[800],
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  data['dateTime'] != null
                                                      ? (data['dateTime']
                                                                as Timestamp)
                                                            .toDate()
                                                            .toString()
                                                            .substring(0, 16)
                                                      : '',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
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

                        if (clubs.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              context.localization.popularClubs,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: clubs.length,
                              itemBuilder: (context, index) {
                                final club = clubs[index];
                                return ClubCard(club: club, onTap: () {});
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              } else {
                return const LoadingWidget(message: 'Загрузка данных...');
              }
            },
          ),
        ),
      ),
    );
  }
}
