import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_manager/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';

import '../../../../core/router/app_router.gr.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc_simple.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../unibuddy/data/unibuddy_api.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/club_card.dart';

@RoutePage(name: 'HomeRoute')
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeBloc _homeBloc;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  bool _recLoading = false;
  bool _recFailed = false;
  String? _recExplanation;
  List<String> _recTitles = [];

  static const _categories = [
    'Academic', 'Sports', 'Culture', 'Social', 'Career', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _homeBloc = getIt<HomeBloc>();
    _homeBloc.add(const LoadHomeData());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecommendations());
  }

  void _loadRecommendations() {
    final auth = context.read<AuthBloc>().state;
    if (auth is! Authenticated) return;
    if (auth.user.role != UserRole.student) {
      setState(() {
        _recLoading = false;
        _recFailed = false;
        _recExplanation = null;
        _recTitles = [];
      });
      return;
    }
    if (auth.user.interests.isEmpty) {
      setState(() {
        _recLoading = false;
        _recFailed = false;
        _recExplanation = null;
        _recTitles = [];
      });
      return;
    }

    setState(() {
      _recLoading = true;
      _recFailed = false;
    });

    getIt<UniBuddyApi>()
        .recommend(
      interests: auth.user.interests,
      userName: auth.user.name,
    )
        .then((res) {
      if (!mounted) return;
      setState(() {
        _recLoading = false;
        _recExplanation = res.explanation;
        _recTitles = res.recommendations
            .map((e) => e.title ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
        _recFailed = false;
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() {
        _recLoading = false;
        _recFailed = true;
        _recExplanation = null;
        _recTitles = [];
      });
    });
  }

  @override
  void dispose() {
    _homeBloc.close();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _homeBloc.add(const LoadHomeData());
    _loadRecommendations();
    // Give a small delay so the pull-to-refresh indicator shows
    await Future.delayed(const Duration(milliseconds: 600));
  }

  String _getCategoryName(BuildContext context, String category) {
    switch (category) {
      case 'Academic':
        return context.localization.catAcademic;
      case 'Sports':
        return context.localization.catSports;
      case 'Culture':
        return context.localization.catCulture;
      case 'Social':
        return context.localization.catSocial;
      case 'Career':
        return context.localization.catCareer;
      case 'Other':
        return context.localization.catOther;
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _homeBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) {
          if (prev is Authenticated && curr is Authenticated) {
            return prev.user.interests.join('|') !=
                curr.user.interests.join('|');
          }
          return false;
        },
        listener: (_, __) => _loadRecommendations(),
        child: Scaffold(
        appBar: AppBar(
          title: Text(context.localization.appTitle),
          elevation: 0,
        ),
        floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated &&
                authState.user.role == UserRole.club) {
              return FloatingActionButton.extended(
                onPressed: () =>
                    context.router.push(CreateEventRoute()),
                icon: const Icon(Icons.add),
                label: Text(context.localization.createEvent),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        body: Column(
          children: [
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is! Authenticated ||
                    authState.user.role != UserRole.student) {
                  return const SizedBox.shrink();
                }
                if (_recLoading && _recExplanation == null) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: LinearProgressIndicator(),
                  );
                }
                if (authState.user.interests.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.interests_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(context.localization.fillInterestsHint),
                        dense: true,
                      ),
                    ),
                  );
                }
                if (_recFailed) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      context.localization.recoCouldNotLoad,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                if (_recExplanation == null || _recExplanation!.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.localization.recommendationForYou,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_recExplanation!),
                          if (_recTitles.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              _recTitles.join(' · '),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // ── Search bar ──────────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
                decoration: InputDecoration(
                  hintText: context.localization.searchEvents,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withAlpha(80),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // ── Category filter chips ────────────────────────────────────
            SizedBox(
              height: 40,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(context.localization.all),
                      selected: _selectedCategory == null,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                    ),
                  ),
                  ..._categories.map((cat) => Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(_getCategoryName(context, cat)),
                          selected: _selectedCategory == cat,
                          onSelected: (sel) => setState(
                              () => _selectedCategory = sel ? cat : null),
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ── Main content ─────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is HomeError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 48, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(state.message, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh),
                            label: Text(context.localization.retry),
                          ),
                        ],
                      ),
                    );
                  }

                  // HomeLoaded or HomeEmpty — show content
                  final popularClubs =
                      state is HomeLoaded ? state.popularClubs : [];

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('events')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('${context.localization.errorLabel}: ${snapshot.error}'));
                        }

                        final allDocs = snapshot.data?.docs ?? [];

                        // Apply search + category filter locally
                        final filtered = allDocs.where((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>;
                          final title = (data['title'] ?? '')
                              .toString()
                              .toLowerCase();
                          final desc = (data['description'] ?? '')
                              .toString()
                              .toLowerCase();
                          final category =
                              (data['category'] ?? '').toString();
                          final matchSearch = _searchQuery.isEmpty ||
                              title.contains(
                                  _searchQuery.toLowerCase()) ||
                              desc.contains(_searchQuery.toLowerCase());
                          final matchCat = _selectedCategory == null ||
                              category == _selectedCategory;
                          return matchSearch && matchCat;
                        }).toList();

                        // Empty state
                        if (filtered.isEmpty &&
                            snapshot.connectionState !=
                                ConnectionState.waiting) {
                          return _buildEmptyState(context);
                        }

                        return ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (snapshot.connectionState ==
                                ConnectionState.waiting)
                              const Center(
                                  child: CircularProgressIndicator()),

                            if (filtered.isNotEmpty) ...[
                              Text(
                                context.localization.comingEvents,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GridView.builder(
                                shrinkWrap: true,
                                physics:
                                    const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 24,
                                  childAspectRatio: 0.65,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final doc = filtered[index];
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  return _buildEventGridCard(
                                      context, doc.id, data);
                                },
                              ),
                              const SizedBox(height: 24),
                            ],

                            if (popularClubs.isNotEmpty) ...[
                              Text(
                                context.localization.popularClubs,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...popularClubs.map(
                                (club) => ClubCard(
                                  club: club,
                                  onTap: () => context.router.push(
                                    ClubDetailRoute(
                                      clubId: club.id,
                                      clubName: club.name,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off,
              size: 72,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withAlpha(76)),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != null
                ? context.localization.nothingFound
                : context.localization.noEventsYet,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() {
                _searchQuery = '';
                _searchCtrl.clear();
                _selectedCategory = null;
              }),
              child: Text(context.localization.resetFilters),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventGridCard(
      BuildContext context, String id, Map<String, dynamic> data) {
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
                  child: (data['imageUrl'] != null &&
                          data['imageUrl'].toString().isNotEmpty)
                      ? Image.network(
                          data['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.event,
                              color: Colors.grey,
                              size: 40),
                        )
                      : const Icon(Icons.event,
                          color: Colors.grey, size: 40),
                ),
                if (data['clubName'] != null &&
                    data['clubName'].toString().isNotEmpty)
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        data['clubName'],
                        style: const TextStyle(
                          fontSize: 11,
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
          const SizedBox(height: 8),
          Text(
            data['title'] ?? context.localization.noTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            _getCategoryName(context, (data['category'] ?? '').toString()).toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
