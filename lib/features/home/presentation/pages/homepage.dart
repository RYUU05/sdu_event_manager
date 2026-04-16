import 'package:event_manager/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:auto_route/auto_route.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/event_card.dart';
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
    final refreshController = RefreshController();

    return BlocProvider(
      create: (context) => homeBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.localization.appTitle),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          elevation: 0,
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
                final clubs = state is HomeLoaded
                    ? state.popularClubs
                    : (state as HomeRefreshing).popularClubs;

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
                        if (events.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              context.localization.comingEvents,
                              style: Theme.of(context).textTheme.titleLarge
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
                              itemCount: events.length,
                              itemBuilder: (context, index) {
                                final event = events[index];
                                return SizedBox(
                                  width: 350,
                                  child: EventCard(event: event, onTap: () {}),
                                );
                              },
                            ),
                          ),
                        ],

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
