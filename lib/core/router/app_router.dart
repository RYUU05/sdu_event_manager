import 'package:auto_route/auto_route.dart';
import 'package:event_manager/core/router/app_router.gr.dart';
import 'auth_guard.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(path: '/login', page: LoginRoute.page, initial: true),
        AutoRoute(path: '/register', page: RegisterRoute.page),
        AutoRoute(path: '/forgot-password', page: ForgotPasswordRoute.page),
        AutoRoute(
          path: '/navbar',
          page: AppShellRoute.page,
          guards: [AuthGuard()],
          children: [
            AutoRoute(path: 'home', page: HomeRoute.page),
            AutoRoute(path: 'unibuddy', page: UniBuddyRoute.page),
            AutoRoute(path: 'my-events', page: MyEventsRoute.page),
            AutoRoute(path: 'setting', page: SettingsRoute.page),
          ],
        ),
        AutoRoute(
          path: '/profile',
          page: ProfileRoute.page,
          guards: [AuthGuard()],
        ),
        AutoRoute(
          path: '/create-event',
          page: CreateEventRoute.page,
          guards: [AuthGuard()],
        ),
        AutoRoute(path: '/event/:id', page: EventDetailRoute.page),
        AutoRoute(path: '/club/:id', page: ClubDetailRoute.page),

        // ─── Новые маршруты для системы заявок ───────────────────────────────
        AutoRoute(
          path: '/apply-club',
          page: CreateClubApplicationRoute.page,
          guards: [AuthGuard()],
        ),
        AutoRoute(
          path: '/my-applications',
          page: MyApplicationsRoute.page,
          guards: [AuthGuard()],
        ),
        AutoRoute(
          path: '/admin/applications',
          page: AdminApplicationsRoute.page,
          guards: [AuthGuard()],
        ),
      ];
}
