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
                onPressed: () => context.router.push(CreateEventRoute()),
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

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          return _buildEventGridCard(context, doc.id, data);
                        },
                      ),

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

  Widget _buildEventGridCard(BuildContext context, String id, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () => context.router.push(EventDetailRoute(eventId: id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[200],
                  ),
                  clipBehavior: Clip.antiAlias,
                  width: double.infinity,
                  child: (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty)
                      ? Image.network(
                          data['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.event, color: Colors.grey, size: 40),
                        )
                      : const Icon(Icons.event, color: Colors.grey, size: 40),
                ),
                if (data['clubName'] != null && data['clubName'].toString().isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(230),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        data['clubName'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data['title'] ?? 'No title',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            (data['category'] ?? '').toString().toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
