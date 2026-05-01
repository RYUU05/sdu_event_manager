import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/features/auth/domain/entities/user_entity.dart';
import 'package:event_manager/features/auth/presentation/bloc/auth_bloc_simple.dart';
import 'package:event_manager/features/home/domain/entities/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.gr.dart';
import '../../data/datasources/firebase_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';

@RoutePage(name: 'EventDetailRoute')
class EventDetailPage extends StatefulWidget {
  final String eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late final HomeRepositoryImpl _repo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repo = HomeRepositoryImpl(
      dataSource: FirebaseDataSourceImpl(
        firestore: FirebaseFirestore.instance,
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      ),
      auth: FirebaseAuth.instance,
    );
  }

  Future<void> _toggle(bool isRegistered, String eventId) async {
    setState(() => _isLoading = true);
    try {
      if (isRegistered) {
        await _repo.unregisterFromEvent(eventId);
      } else {
        await _repo.registerForEvent(eventId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check role via AuthBloc
    final authState = context.watch<AuthBloc>().state;
    final isStudent = authState is Authenticated && authState.user.role == UserRole.student;
    final isClub = authState is Authenticated && authState.user.role == UserRole.club;
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    
    // Show participate button strictly for students
    final showButton = isLoggedIn && isStudent;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .snapshots(),
        builder: (context, eventSnap) {
          if (eventSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!eventSnap.hasData || !eventSnap.data!.exists) {
            return const Center(child: Text('Ивент не найден'));
          }

          final data = eventSnap.data!.data() as Map<String, dynamic>;
          final title = data['title'] ?? 'Без названия';
          final description = data['description'] ?? '';
          final location = data['location'] ?? '';
          final imageUrl = data['imageUrl'] ?? '';
          final category = data['category'] ?? '';
          final clubId = data['clubId'] ?? '';
          final clubName = data['clubName'] ?? 'Неизвестный клуб';
          final maxP = data['maxParticipants'] ?? 0;
          final currP = data['currentParticipants'] ?? 0;
          final percentage = maxP > 0 ? (currP / maxP).clamp(0.0, 1.0) : 0.0;

          DateTime? dateTime;
          if (data['dateTime'] != null) {
            dateTime = (data['dateTime'] as Timestamp).toDate();
          } else if (data['date'] != null) {
            try {
              dateTime = DateTime.parse(data['date']);
            } catch (_) {}
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.router.maybePop(),
                ),
                actions: [
                  if (isClub && clubId == currentUserId) ...[
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Редактировать ивент',
                      onPressed: () {
                        final ev = Event(
                          id: widget.eventId,
                          title: title,
                          description: description,
                          imageUrl: imageUrl,
                          date: dateTime ?? DateTime.now(),
                          registrationDeadline: dateTime ?? DateTime.now(),
                          location: location,
                          maxParticipants: maxP,
                          currentParticipants: currP,
                          clubId: clubId,
                          clubName: clubName,
                          tags: [category],
                          isRegistered: false,
                          isActive: true,
                        );
                        context.router.push(CreateEventRoute(eventToEdit: ev));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Удалить ивент',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Удалить ивент?'),
                            content: const Text('Это действие нельзя отменить.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Отмена'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Удалить'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          if (!context.mounted) return;
                          setState(() => _isLoading = true);
                          try {
                            await _repo.deleteEvent(widget.eventId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ивент удален')),
                              );
                              context.router.maybePop();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ошибка удаления: $e')),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        }
                      },
                    ),
                  ],
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                  background: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              _buildPlaceholder(context),
                        )
                      : _buildPlaceholder(context),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category chip
                      if (category.isNotEmpty)
                        Chip(
                          label: Text(category),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),

                      const SizedBox(height: 16),

                      // Organizer (Club Name)
                      _InfoRow(
                        icon: Icons.business_outlined,
                        text: 'Организатор: $clubName',
                      ),
                      const SizedBox(height: 8),

                      // Date & Location
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        text: dateTime != null
                            ? DateFormat('dd MMM yyyy, HH:mm').format(dateTime)
                            : '—',
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(icon: Icons.location_on_outlined, text: location),

                      const SizedBox(height: 16),

                      // Participants progress
                      Row(
                        children: [
                          Icon(Icons.people_outline,
                              size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            maxP > 0 ? '$currP / $maxP участников' : '$currP участников (без ограничений)',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(
                            percentage < 0.5
                                ? Colors.green
                                : percentage < 0.8
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Описание',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description.isNotEmpty ? description : 'Нет описания',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              color: Colors.grey[800],
                            ),
                      ),

                      const SizedBox(height: 32),

                      // Register / Unregister button
                      if (showButton)
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUserId)
                              .snapshots(),
                          builder: (context, regSnap) {
                            final userData = regSnap.data?.data() as Map<String, dynamic>?;
                            final List<dynamic> registeredEvents = userData?['registeredEvents'] ?? [];
                            final isRegistered = registeredEvents.contains(widget.eventId);
                            // isFull only when maxP is set and slots ran out
                            final isFull =
                                maxP > 0 && currP >= maxP && !isRegistered;

                            return SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton.icon(
                                onPressed: (_isLoading || isFull)
                                    ? null
                                    : () => _toggle(
                                          isRegistered,
                                          widget.eventId,
                                        ),
                                icon: _isLoading
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: isRegistered
                                              ? Colors.red
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(isRegistered
                                        ? Icons.cancel_outlined
                                        : Icons.check_circle_outline),
                                label: Text(
                                  isFull
                                      ? 'Мест нет'
                                      : isRegistered
                                          ? 'Отменить участие'
                                          : 'Участвовать',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                style: FilledButton.styleFrom(
                                  backgroundColor: isRegistered
                                      ? Colors.red.withAlpha(25)
                                      : Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                  foregroundColor: isRegistered
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 16),

                      // Go to my events shortcut
                      if (showButton)
                        Center(
                          child: TextButton.icon(
                            onPressed: () =>
                                context.router.navigate(const MyEventsRoute()),
                            icon: const Icon(Icons.bookmarks_outlined),
                            label: const Text('Мои ивенты'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(Icons.event, size: 64, color: Colors.white54),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
