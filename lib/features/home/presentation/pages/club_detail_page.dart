import 'package:auto_route/auto_route.dart';
import 'package:event_manager/core/extensions/context_extensions.dart';
import 'package:event_manager/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc_simple.dart';
import '../../domain/repositories/home_repository.dart';

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
  late final HomeRepository _repo;
  bool _followLoading = false;

  @override
  void initState() {
    super.initState();
    // ИСПОЛЬЗУЕМ DI (sl), а не ручное создание!
    _repo = sl<HomeRepository>();
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
    final isStudent = authState is Authenticated && authState.user.role == UserRole.student;

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).snapshots(),
        builder: (context, clubSnap) {
          final clubData = clubSnap.data?.data() as Map<String, dynamic>? ?? {};
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
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  background: imageUrl.isNotEmpty 
                      ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(context))
                      : _placeholder(context),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category.isNotEmpty)
                        Chip(label: Text(category), backgroundColor: Theme.of(context).colorScheme.primaryContainer),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.people_outline, size: 18, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 6),
                          Text('$memberCount ${context.localization.memberCount}'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (description.isNotEmpty) ...[
                        Text(context.localization.aboutClub, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(description),
                      ],
                      const SizedBox(height: 20),
                      if (isStudent)
                        StreamBuilder<bool>(
                          stream: _repo.isFollowingClub(widget.clubId),
                          builder: (context, snap) {
                            final isFollowing = snap.data ?? false;
                            return SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _followLoading ? null : () => _toggleFollow(isFollowing),
                                icon: _followLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator()) : Icon(isFollowing ? Icons.favorite : Icons.favorite_border),
                                label: Text(isFollowing ? context.localization.following : context.localization.follow),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              // Секция ивентов клуба здесь...
            ],
          );
        },
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(color: Colors.grey[300], child: const Icon(Icons.groups, size: 64));
}