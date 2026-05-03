// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i12;
import 'package:event_manager/core/widgets/app_shell.dart' as _i1;
import 'package:event_manager/features/auth/presentation/pages/forgot_password_page.dart'
    as _i5;
import 'package:event_manager/features/auth/presentation/pages/login_page.dart'
    as _i7;
import 'package:event_manager/features/auth/presentation/pages/register_page.dart'
    as _i9;
import 'package:event_manager/features/events/presentation/pages/create_event_page.dart'
    as _i3;
import 'package:event_manager/features/home/domain/entities/event.dart' as _i14;
import 'package:event_manager/features/home/presentation/pages/club_detail_page.dart'
    as _i2;
import 'package:event_manager/features/home/presentation/pages/event_detail_page.dart'
    as _i4;
import 'package:event_manager/features/home/presentation/pages/homepage.dart'
    as _i6;
import 'package:event_manager/features/my_events/presentation/pages/my_events_page.dart'
    as _i8;
import 'package:event_manager/features/settings/presentation/pages/settings_page.dart'
    as _i10;
import 'package:event_manager/features/unibuddy/presentation/pages/unibuddy_chat_page.dart'
    as _i11;
import 'package:flutter/material.dart' as _i13;

/// generated route for
/// [_i1.AppShell]
class AppShellRoute extends _i12.PageRouteInfo<void> {
  const AppShellRoute({List<_i12.PageRouteInfo>? children})
    : super(AppShellRoute.name, initialChildren: children);

  static const String name = 'AppShellRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i1.AppShell();
    },
  );
}

/// generated route for
/// [_i2.ClubDetailPage]
class ClubDetailRoute extends _i12.PageRouteInfo<ClubDetailRouteArgs> {
  ClubDetailRoute({
    _i13.Key? key,
    required String clubId,
    required String clubName,
    List<_i12.PageRouteInfo>? children,
  }) : super(
         ClubDetailRoute.name,
         args: ClubDetailRouteArgs(
           key: key,
           clubId: clubId,
           clubName: clubName,
         ),
         initialChildren: children,
       );

  static const String name = 'ClubDetailRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ClubDetailRouteArgs>();
      return _i2.ClubDetailPage(
        key: args.key,
        clubId: args.clubId,
        clubName: args.clubName,
      );
    },
  );
}

class ClubDetailRouteArgs {
  const ClubDetailRouteArgs({
    this.key,
    required this.clubId,
    required this.clubName,
  });

  final _i13.Key? key;

  final String clubId;

  final String clubName;

  @override
  String toString() {
    return 'ClubDetailRouteArgs{key: $key, clubId: $clubId, clubName: $clubName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ClubDetailRouteArgs) return false;
    return key == other.key &&
        clubId == other.clubId &&
        clubName == other.clubName;
  }

  @override
  int get hashCode => key.hashCode ^ clubId.hashCode ^ clubName.hashCode;
}

/// generated route for
/// [_i3.CreateEventPage]
class CreateEventRoute extends _i12.PageRouteInfo<CreateEventRouteArgs> {
  CreateEventRoute({
    _i13.Key? key,
    _i14.Event? eventToEdit,
    List<_i12.PageRouteInfo>? children,
  }) : super(
         CreateEventRoute.name,
         args: CreateEventRouteArgs(key: key, eventToEdit: eventToEdit),
         initialChildren: children,
       );

  static const String name = 'CreateEventRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateEventRouteArgs>(
        orElse: () => const CreateEventRouteArgs(),
      );
      return _i3.CreateEventPage(key: args.key, eventToEdit: args.eventToEdit);
    },
  );
}

class CreateEventRouteArgs {
  const CreateEventRouteArgs({this.key, this.eventToEdit});

  final _i13.Key? key;

  final _i14.Event? eventToEdit;

  @override
  String toString() {
    return 'CreateEventRouteArgs{key: $key, eventToEdit: $eventToEdit}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateEventRouteArgs) return false;
    return key == other.key && eventToEdit == other.eventToEdit;
  }

  @override
  int get hashCode => key.hashCode ^ eventToEdit.hashCode;
}

/// generated route for
/// [_i4.EventDetailPage]
class EventDetailRoute extends _i12.PageRouteInfo<EventDetailRouteArgs> {
  EventDetailRoute({
    _i13.Key? key,
    required String eventId,
    List<_i12.PageRouteInfo>? children,
  }) : super(
         EventDetailRoute.name,
         args: EventDetailRouteArgs(key: key, eventId: eventId),
         initialChildren: children,
       );

  static const String name = 'EventDetailRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EventDetailRouteArgs>();
      return _i4.EventDetailPage(key: args.key, eventId: args.eventId);
    },
  );
}

class EventDetailRouteArgs {
  const EventDetailRouteArgs({this.key, required this.eventId});

  final _i13.Key? key;

  final String eventId;

  @override
  String toString() {
    return 'EventDetailRouteArgs{key: $key, eventId: $eventId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EventDetailRouteArgs) return false;
    return key == other.key && eventId == other.eventId;
  }

  @override
  int get hashCode => key.hashCode ^ eventId.hashCode;
}

/// generated route for
/// [_i5.ForgotPasswordPage]
class ForgotPasswordRoute extends _i12.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i12.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i5.ForgotPasswordPage();
    },
  );
}

/// generated route for
/// [_i6.HomePage]
class HomeRoute extends _i12.PageRouteInfo<void> {
  const HomeRoute({List<_i12.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i6.HomePage();
    },
  );
}

/// generated route for
/// [_i7.LoginPage]
class LoginRoute extends _i12.PageRouteInfo<void> {
  const LoginRoute({List<_i12.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i7.LoginPage();
    },
  );
}

/// generated route for
/// [_i8.MyEventsPage]
class MyEventsRoute extends _i12.PageRouteInfo<void> {
  const MyEventsRoute({List<_i12.PageRouteInfo>? children})
    : super(MyEventsRoute.name, initialChildren: children);

  static const String name = 'MyEventsRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i8.MyEventsPage();
    },
  );
}

/// generated route for
/// [_i9.RegisterPage]
class RegisterRoute extends _i12.PageRouteInfo<void> {
  const RegisterRoute({List<_i12.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i9.RegisterPage();
    },
  );
}

/// generated route for
/// [_i10.SettingsPage]
class SettingsRoute extends _i12.PageRouteInfo<void> {
  const SettingsRoute({List<_i12.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i10.SettingsPage();
    },
  );
}

/// generated route for
/// [_i11.UniBuddyChatPage]
class UniBuddyRoute extends _i12.PageRouteInfo<void> {
  const UniBuddyRoute({List<_i12.PageRouteInfo>? children})
    : super(UniBuddyRoute.name, initialChildren: children);

  static const String name = 'UniBuddyRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i11.UniBuddyChatPage();
    },
  );
}
