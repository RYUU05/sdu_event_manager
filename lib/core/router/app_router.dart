import 'package:auto_route/auto_route.dart';
import 'package:event_manager/core/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(path: '/login', page: LoginRoute.page, initial: true),
    AutoRoute(path: '/register', page: RegisterRoute.page),
    AutoRoute(path: '/create-event', page: CreateEventRoute.page),
    AutoRoute(
      path: '/navbar',
      page: AppShellRoute.page,
      children: [
        AutoRoute(path: 'home', page: HomeRoute.page),
        AutoRoute(path: 'setting', page: SettingsRoute.page),
      ],
    ),
  ];
}
