import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/features/auth/presentation/bloc/auth_bloc_simple.dart';
import 'package:event_manager/features/home/data/datasources/firebase_data_source.dart';
import 'package:event_manager/features/home/data/repositories/home_repository_impl.dart';
import 'package:event_manager/features/home/domain/entities/event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.gr.dart';
import '../bloc/my_events_bloc.dart';
import '../bloc/my_events_event.dart';
import '../bloc/my_events_state.dart';

@RoutePage(name: 'MyEventsRoute')
class MyEventsPage extends StatelessWidget {
  const MyEventsPage({super.key});

  static MyEventsBloc _createBloc() {
    final auth = FirebaseAuth.instance;
    final dataSource = FirebaseDataSourceImpl(
      firestore: FirebaseFirestore.instance,
      userId: auth.currentUser?.uid ?? '',
    );
    final repo = HomeRepositoryImpl(dataSource: dataSource, auth: auth);
    return MyEventsBloc(repo);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _createBloc()..add(LoadMyEvents()),
      child: const _MyEventsView(),
    );
  }
}

class _MyEventsView extends StatelessWidget {
  const _MyEventsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои ивенты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<MyEventsBloc>().add(LoadMyEvents()),
          ),
        ],
      ),
      body: BlocBuilder<MyEventsBloc, MyEventsState>(
        builder: (context, state) {
          if (state is MyEventsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyEventsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () =>
                        context.read<MyEventsBloc>().add(LoadMyEvents()),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          if (state is MyEventsLoaded) {
            if (state.events.isEmpty) {
              return _EmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = state.events[index];
                return _MyEventCard(event: event);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmarks_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'Нет записанных ивентов',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите «Участвовать» на ивенте,\nчтобы он появился здесь',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.router.navigate(const HomeRoute()),
            icon: const Icon(Icons.search),
            label: const Text('Найти ивенты'),
          ),
        ],
      ),
    );
  }
}

class _MyEventCard extends StatelessWidget {
  final Event event;

  const _MyEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final hasImage = event.imageUrl.isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => context.router.push(EventDetailRoute(eventId: event.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (hasImage)
              Image.network(
                event.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder(context),
              )
            else
              _imagePlaceholder(context),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Remove button
                      _RemoveButton(eventId: event.id),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(event.date),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      if (event.location.isNotEmpty) ...[
                        Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Registered badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                size: 14, color: Colors.green[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Вы записаны',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      height: 100,
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.event, size: 40, color: Colors.white54),
    );
  }
}

class _RemoveButton extends StatefulWidget {
  final String eventId;

  const _RemoveButton({required this.eventId});

  @override
  State<_RemoveButton> createState() => _RemoveButtonState();
}

class _RemoveButtonState extends State<_RemoveButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.delete_outline, color: Colors.red),
      tooltip: 'Убрать из моих ивентов',
      onPressed: _loading
          ? null
          : () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Убрать ивент?'),
                  content: const Text(
                    'Вы отмените участие в этом ивенте.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Отмена'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Убрать'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && mounted) {
                setState(() => _loading = true);
                context
                    .read<MyEventsBloc>()
                    .add(RemoveMyEvent(widget.eventId));
              }
            },
    );
  }
}
