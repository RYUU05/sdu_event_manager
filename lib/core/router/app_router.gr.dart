// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i15;
import 'package:event_manager/core/widgets/app_shell.dart' as _i2;
import 'package:event_manager/features/applications/presentation/pages/admin_applications_page.dart'
    as _i1;
import 'package:event_manager/features/applications/presentation/pages/create_club_application_page.dart'
    as _i4;
import 'package:event_manager/features/applications/presentation/pages/my_applications_page.dart'
    as _i10;
import 'package:event_manager/features/auth/presentation/pages/forgot_password_page.dart'
    as _i7;
import 'package:event_manager/features/auth/presentation/pages/login_page.dart'
    as _i9;
import 'package:event_manager/features/auth/presentation/pages/register_page.dart'
    as _i12;
import 'package:event_manager/features/events/presentation/pages/create_event_page.dart'
    as _i5;
import 'package:event_manager/features/home/domain/entities/event.dart' as _i17;
import 'package:event_manager/features/home/presentation/pages/club_detail_page.dart'
    as _i3;
import 'package:event_manager/features/home/presentation/pages/event_detail_page.dart'
    as _i6;
import 'package:event_manager/features/home/presentation/pages/homepage.dart'
    as _i8;
import 'package:event_manager/features/my_events/presentation/pages/my_events_page.dart'
    as _i11;
import 'package:event_manager/features/settings/presentation/pages/settings_page.dart'
    as _i13;
import 'package:event_manager/features/unibuddy/presentation/pages/unibuddy_chat_page.dart'
    as _i14;
import 'package:flutter/material.dart' as _i16;

/// generated route for
/// [_i1.AdminApplicationsPage]
class AdminApplicationsRoute extends _i15.PageRouteInfo<void> {
  const AdminApplicationsRoute({List<_i15.PageRouteInfo>? children})
    : super(AdminApplicationsRoute.name, initialChildren: children);

  static const String name = 'AdminApplicationsRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i1.AdminApplicationsPage();
    },
  );
}

/// generated route for
/// [_i2.AppShell]
class AppShellRoute extends _i15.PageRouteInfo<void> {
  const AppShellRoute({List<_i15.PageRouteInfo>? children})
    : super(AppShellRoute.name, initialChildren: children);

  static const String name = 'AppShellRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i2.AppShell();
    },
  );
}

/// generated route for
/// [_i3.ClubDetailPage]
class ClubDetailRoute extends _i15.PageRouteInfo<ClubDetailRouteArgs> {
  ClubDetailRoute({
    _i16.Key? key,
    required String clubId,
    required String clubName,
    List<_i15.PageRouteInfo>? children,
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

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ClubDetailRouteArgs>();
      return _i3.ClubDetailPage(
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

  final _i16.Key? key;

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
/// [_i4.CreateClubApplicationPage]
class CreateClubApplicationRoute extends _i15.PageRouteInfo<void> {
  const CreateClubApplicationRoute({List<_i15.PageRouteInfo>? children})
    : super(CreateClubApplicationRoute.name, initialChildren: children);

  static const String name = 'CreateClubApplicationRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i4.CreateClubApplicationPage();
    },
  );
}

/// generated route for
/// [_i5.CreateEventPage]
class CreateEventRoute extends _i15.PageRouteInfo<CreateEventRouteArgs> {
  CreateEventRoute({
    _i16.Key? key,
    _i17.Event? eventToEdit,
    List<_i15.PageRouteInfo>? children,
  }) : super(
         CreateEventRoute.name,
         args: CreateEventRouteArgs(key: key, eventToEdit: eventToEdit),
         initialChildren: children,
       );

  static const String name = 'CreateEventRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<CreateEventRouteArgs>(
        orElse: () => const CreateEventRouteArgs(),
      );
      return _i5.CreateEventPage(key: args.key, eventToEdit: args.eventToEdit);
    },
  );
}

class CreateEventRouteArgs {
  const CreateEventRouteArgs({this.key, this.eventToEdit});

  final _i16.Key? key;

  final _i17.Event? eventToEdit;

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
/// [_i6.EventDetailPage]
class EventDetailRoute extends _i15.PageRouteInfo<EventDetailRouteArgs> {
  EventDetailRoute({
    _i16.Key? key,
    required String eventId,
    List<_i15.PageRouteInfo>? children,
  }) : super(
         EventDetailRoute.name,
         args: EventDetailRouteArgs(key: key, eventId: eventId),
         initialChildren: children,
       );

  static const String name = 'EventDetailRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EventDetailRouteArgs>();
      return _i6.EventDetailPage(key: args.key, eventId: args.eventId);
    },
  );
}

class EventDetailRouteArgs {
  const EventDetailRouteArgs({this.key, required this.eventId});

  final _i16.Key? key;

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
/// [_i7.ForgotPasswordPage]
class ForgotPasswordRoute extends _i15.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i15.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i7.ForgotPasswordPage();
    },
  );
}

/// generated route for
/// [_i8.HomePage]
class HomeRoute extends _i15.PageRouteInfo<void> {
  const HomeRoute({List<_i15.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i8.HomePage();
    },
  );
}

/// generated route for
/// [_i9.LoginPage]
class LoginRoute extends _i15.PageRouteInfo<void> {
  const LoginRoute({List<_i15.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i9.LoginPage();
    },
  );
}

/// generated route for
/// [_i10.MyApplicationsPage]
class MyApplicationsRoute extends _i15.PageRouteInfo<void> {
  const MyApplicationsRoute({List<_i15.PageRouteInfo>? children})
    : super(MyApplicationsRoute.name, initialChildren: children);

  static const String name = 'MyApplicationsRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i10.MyApplicationsPage();
    },
  );
}

/// generated route for
/// [_i11.MyEventsPage]
class MyEventsRoute extends _i15.PageRouteInfo<void> {
  const MyEventsRoute({List<_i15.PageRouteInfo>? children})
    : super(MyEventsRoute.name, initialChildren: children);

  static const String name = 'MyEventsRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i11.MyEventsPage();
    },
  );
}

/// generated route for
/// [_i12.RegisterPage]
class RegisterRoute extends _i15.PageRouteInfo<void> {
  const RegisterRoute({List<_i15.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i12.RegisterPage();
    },
  );
}

/// generated route for
/// [_i13.SettingsPage]
class SettingsRoute extends _i15.PageRouteInfo<void> {
  const SettingsRoute({List<_i15.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i13.SettingsPage();
    },
  );
}

/// generated route for
/// [_i14.UniBuddyChatPage]
class UniBuddyRoute extends _i15.PageRouteInfo<void> {
  const UniBuddyRoute({List<_i15.PageRouteInfo>? children})
    : super(UniBuddyRoute.name, initialChildren: children);

  static const String name = 'UniBuddyRoute';

  static _i15.PageInfo page = _i15.PageInfo(
    name,
    builder: (data) {
      return const _i14.UniBuddyChatPage();
    },
  );
}
