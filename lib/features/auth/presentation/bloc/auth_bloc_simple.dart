import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:event_manager/features/auth/domain/entities/user_entity.dart';
import 'package:event_manager/features/auth/domain/repositories/auth_repository.dart';

// ─── Events ────────────────────────────────────────────────────────────────

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

class ResetPasswordRequested extends AuthEvent {
  final String email;
  ResetPasswordRequested(this.email);
}

// ─── States ────────────────────────────────────────────────────────────────

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

class PasswordResetSent extends AuthState {}

// ─── Bloc ──────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;
  StreamSubscription<UserEntity?>? _sub;

  AuthBloc(this._repo) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    on<UserChanged>(_onUserChanged);
    on<ResetPasswordRequested>(_onResetPassword);

    _sub = _repo.user.listen((user) => add(UserChanged(user)));
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final user = await _repo.login(event.email, event.password);
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(AuthError('Неверный email или пароль'));
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
      emit(AuthError('Ошибка регистрации. Проверьте данные.'));
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

  Future<void> _onResetPassword(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _repo.resetPassword(event.email);
      emit(PasswordResetSent());
    } catch (e) {
      emit(AuthError('Ошибка отправки письма. Проверьте email.'));
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
