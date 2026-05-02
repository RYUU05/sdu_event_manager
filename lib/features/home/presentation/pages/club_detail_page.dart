import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/features/auth/presentation/bloc/auth_bloc_simple.dart';
import 'package:event_manager/features/home/data/datasources/firebase_data_source.dart';
import 'package:event_manager/features/home/data/repositories/home_repository_impl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_router.gr.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'package:event_manager/core/extensions/context_extensions.dart';

@RoutePage(name: 'ClubDetailRoute')
class ClubDetailPage extends StatefulWidget {
  final String clubId;
  final String clubName;

  const ClubDetailPage({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  State<ClubDetailPage> createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends State<ClubDetailPage> {
  late final HomeRepositoryImpl _repo;
  bool _followLoading = false;

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

  Future<void> _toggleFollow(bool isFollowing) async {
    setState(() => _followLoading = true);
    try {
      if (isFollowing) {
        await _repo.unfollowClub(widget.clubId);
      } else {
        await _repo.followClub(widget.clubId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.localization.errorLabel}: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _followLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isStudent =
        authState is Authenticated && authState.user.role == UserRole.student;

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clubs')
            .doc(widget.clubId)
            .snapshots(),
        builder: (context, clubSnap) {
          final clubData =
              clubSnap.data?.data() as Map<String, dynamic>? ?? {};
          final name = clubData['name'] ?? widget.clubName;
          final description = clubData['description'] ?? '';
          final imageUrl = clubData['imageUrl'] ?? '';
          final category = clubData['category'] ?? '';
          final memberCount = clubData['memberCount'] ?? 0;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.router.maybePop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                  background: imageUrl.isNotEmpty
                      ? Image.network(imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _placeholder(context))
                      : _placeholder(context),
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
                      const SizedBox(height: 12),

                      // Stats row
                      Row(
                        children: [
                          Icon(Icons.people_outline,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 6),
                           Text(
                            '$memberCount ${context.localization.memberCount}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Description
                      if (description.isNotEmpty) ...[
                        Text(
                          context.localization.aboutClub,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1.6, color: Colors.grey[800]),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Follow button (only for students)
                      if (isStudent)
                        StreamBuilder<bool>(
                          stream: _repo.isFollowingClub(widget.clubId),
                          builder: (context, snap) {
                            final isFollowing = snap.data ?? false;
                            return SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: _followLoading
                                    ? null
                                    : () => _toggleFollow(isFollowing),
                                icon: _followLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : Icon(isFollowing
                                        ? Icons.favorite
                                        : Icons.favorite_border),
                                label: Text(isFollowing
                                    ? context.localization.following
                                    : context.localization.follow),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isFollowing
                                      ? Colors.red
                                      : Theme.of(context).colorScheme.primary,
                                  side: BorderSide(
                                    color: isFollowing
                                        ? Colors.red
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 28),
                      Text(
                        context.localization.clubEvents,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),

              // Club events stream
              SliverToBoxAdapter(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('events')
                      .where('clubId', isEqualTo: widget.clubId)
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ));
                    }

                    final docs = snap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        child: Center(
                          child: Text(
                            context.localization.noClubEvents,
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final data = doc.data() as Map<String, dynamic>;
                        final title = data['title'] ?? context.localization.noTitle;
                        final location = data['location'] ?? '';
                        final imageUrl =
                            (data['imageUrl'] ?? '').toString();

                        DateTime? dt;
                        if (data['dateTime'] != null) {
                          dt = (data['dateTime'] as Timestamp).toDate();
                        }

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: InkWell(
                            onTap: () => context.router
                                .push(EventDetailRoute(eventId: doc.id)),
                            child: Row(
                              children: [
                                // Thumbnail
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(imageUrl,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _eventPlaceholder())
                                      : _eventPlaceholder(),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                        if (dt != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('dd MMM yyyy, HH:mm')
                                                .format(dt),
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                        if (location.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on_outlined,
                                                  size: 12,
                                                  color: Colors.grey[500]),
                                              const SizedBox(width: 2),
                                              Expanded(
                                                child: Text(location,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[500]),
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(Icons.chevron_right,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(Icons.groups, size: 64, color: Colors.white54),
        ),
      );

  Widget _eventPlaceholder() => Container(
        width: 90,
        height: 90,
        color: Colors.grey[200],
        child: const Icon(Icons.event, color: Colors.grey, size: 32),
      );
}
