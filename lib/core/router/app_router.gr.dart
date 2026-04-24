// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:event_manager/core/widgets/app_shell.dart' as _i1;
import 'package:event_manager/features/auth/presentation/pages/login_page.dart'
    as _i4;
import 'package:event_manager/features/auth/presentation/pages/register_page.dart'
    as _i5;
import 'package:event_manager/features/events/presentation/pages/create_event_page.dart'
    as _i2;
import 'package:event_manager/features/home/presentation/pages/event_detail_page.dart'
    as _i8;
import 'package:event_manager/features/home/presentation/pages/homepage.dart'
    as _i3;
import 'package:event_manager/features/my_events/presentation/pages/my_events_page.dart'
    as _i7;
import 'package:event_manager/features/settings/presentation/pages/settings_page.dart'
    as _i6;
import 'package:flutter/material.dart' as _i10;

/// generated route for
/// [_i1.AppShell]
class AppShellRoute extends _i9.PageRouteInfo<void> {
  const AppShellRoute({List<_i9.PageRouteInfo>? children})
    : super(AppShellRoute.name, initialChildren: children);

  static const String name = 'AppShellRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i1.AppShell();
    },
  );
}

/// generated route for
/// [_i2.CreateEventPage]
class CreateEventRoute extends _i9.PageRouteInfo<void> {
  const CreateEventRoute({List<_i9.PageRouteInfo>? children})
    : super(CreateEventRoute.name, initialChildren: children);

  static const String name = 'CreateEventRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.CreateEventPage();
    },
  );
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i9.PageRouteInfo<void> {
  const HomeRoute({List<_i9.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomePage();
    },
  );
}

/// generated route for
/// [_i4.LoginPage]
class LoginRoute extends _i9.PageRouteInfo<void> {
  const LoginRoute({List<_i9.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i4.LoginPage();
    },
  );
}

/// generated route for
/// [_i5.RegisterPage]
class RegisterRoute extends _i9.PageRouteInfo<void> {
  const RegisterRoute({List<_i9.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i5.RegisterPage();
    },
  );
}

/// generated route for
/// [_i6.SettingsPage]
class SettingsRoute extends _i9.PageRouteInfo<void> {
  const SettingsRoute({List<_i9.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i6.SettingsPage();
    },
  );
}

/// generated route for
/// [_i7.MyEventsPage]
class MyEventsRoute extends _i9.PageRouteInfo<void> {
  const MyEventsRoute({List<_i9.PageRouteInfo>? children})
    : super(MyEventsRoute.name, initialChildren: children);

  static const String name = 'MyEventsRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i7.MyEventsPage();
    },
  );
}

/// generated route for
/// [_i8.EventDetailPage]
class EventDetailRoute extends _i9.PageRouteInfo<EventDetailRouteArgs> {
  EventDetailRoute({
    _i10.Key? key,
    required String eventId,
    List<_i9.PageRouteInfo>? children,
  }) : super(
         EventDetailRoute.name,
         args: EventDetailRouteArgs(key: key, eventId: eventId),
         rawPathParams: {'id': eventId},
         initialChildren: children,
       );

  static const String name = 'EventDetailRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EventDetailRouteArgs>(
        orElse: () => const EventDetailRouteArgs(eventId: ''),
      );
      return _i8.EventDetailPage(key: args.key, eventId: args.eventId);
    },
  );
}

class EventDetailRouteArgs {
  const EventDetailRouteArgs({this.key, required this.eventId});

  final _i10.Key? key;

  final String eventId;

  @override
  String toString() {
    return 'EventDetailRouteArgs{key: $key, eventId: $eventId}';
  }
}
