import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:event_manager/features/auth/domain/entities/user_entity.dart';
import 'package:event_manager/features/auth/domain/repositories/auth_repository.dart';

/// Authentication events
abstract class AuthEvent {
  const AuthEvent();
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
  });
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class UserChanged extends AuthEvent {
  final UserEntity user;

  const UserChanged(this.user);
}

class GetCurrentUserRequested extends AuthEvent {
  const GetCurrentUserRequested();
}

/// Authentication states
abstract class AuthState {
  const AuthState();
}

class Initial extends AuthState {
  const Initial();
}

class Loading extends AuthState {
  const Loading();
}

class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class Failure extends AuthState {
  final String error;

  const Failure(this.error);
}

/// Authentication BLoC with role-based access control
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const Initial()) {
    on<AuthEvent>((event, emit) async {
      if (event is LoginRequested) {
        await _onLoginRequested(event.email, event.password, emit);
      } else if (event is RegisterRequested) {
        await _onRegisterRequested(
          event.email,
          event.password,
          event.name,
          emit,
        );
      } else if (event is LogoutRequested) {
        await _onLogoutRequested(emit);
      } else if (event is UserChanged) {
        await _onUserChanged(event.user, emit);
      } else if (event is GetCurrentUserRequested) {
        await _onGetCurrentUserRequested(emit);
      }
    });
  }

  /// Handle login request
  Future<void> _onLoginRequested(
    String email,
    String password,
    Emitter<AuthState> emit,
  ) async {
    emit(const Loading());

    final result = await _authRepository.login(email, password);

    result.fold(
      (error) => emit(Failure(error)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onRegisterRequested(
    String email,
    String password,
    String name,
    Emitter<AuthState> emit,
  ) async {
    emit(const Loading());

    final result = await _authRepository.register(email, password, name);

    result.fold(
      (error) => emit(Failure(error)),
      (user) => emit(Authenticated(user)),
    );
  }

  /// Handle logout request
  Future<void> _onLogoutRequested(Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(const Unauthenticated());
  }

  /// Handle user changed event
  Future<void> _onUserChanged(UserEntity user, Emitter<AuthState> emit) async {
    emit(Authenticated(user));
  }

  /// Handle get current user request
  Future<void> _onGetCurrentUserRequested(Emitter<AuthState> emit) async {
    emit(const Loading());

    final result = await _authRepository.getCurrentUser();

    result.fold(
      () => emit(const Unauthenticated()),
      (user) => emit(Authenticated(user)),
    );
  }

  /// Check if current user can create events
  bool canCreateEvents() {
    final currentState = state;
    if (currentState is Authenticated) {
      return currentState.user.canCreateEvent;
    }
    return false;
  }

  /// Get current user
  UserEntity? get currentUser {
    final currentState = state;
    if (currentState is Authenticated) {
      return currentState.user;
    }
    return null;
  }
}
