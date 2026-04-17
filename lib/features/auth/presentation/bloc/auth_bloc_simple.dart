import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_manager/features/auth/domain/entities/user_entity.dart';
import 'package:event_manager/features/auth/domain/repositories/auth_repository.dart';

abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final UserRole role;
  RegisterRequested(this.email, this.password, this.name, this.role);
}

class LogoutRequested extends AuthEvent {}

class UserChanged extends AuthEvent {
  final UserEntity? user;
  UserChanged(this.user);
}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;
  StreamSubscription<UserEntity?>? _sub;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    on<UserChanged>(_onUserChanged);

    _sub = _repo.user.listen((user) => add(UserChanged(user)));
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final user = await _repo.login(event.email, event.password);
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(AuthError('Login failed'));
    }
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final user = await _repo.register(
      event.email,
      event.password,
      event.name,
      event.role,
    );
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(AuthError('Registration failed'));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _repo.logout();
    emit(Unauthenticated());
  }

  void _onUserChanged(UserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(Authenticated(event.user!));
    } else {
      emit(Unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }

  bool canCreateEvents() {
    final currentState = state;
    if (currentState is Authenticated) {
      return currentState.user.canCreateEvent;
    }
    return false;
  }

  UserEntity? get currentUser {
    final currentState = state;
    if (currentState is Authenticated) {
      return currentState.user;
    }
    return null;
  }
}
