import 'package:event_manager/features/auth/domain/entities/user_entity.dart';

sealed class AuthResult {
  const AuthResult();
}

final class AuthSuccess extends AuthResult {
  final UserEntity user;
  const AuthSuccess(this.user);
}

final class AuthFailure extends AuthResult {
  final String message;
  const AuthFailure(this.message);
}
