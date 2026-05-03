import '../auth_result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register(
    String email,
    String password,
    String name,
    UserRole role,
  );
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Stream<UserEntity?> get user;
  Future<void> resetPassword(String email);

  /// Обновляет список интересов студента в Firestore и возвращает актуальный профиль.
  Future<UserEntity?> updateInterests(List<String> interests);

  /// Обновляет данные профиля (имя, описание, аватар, баннер).
  Future<UserEntity?> updateProfile({
    String? name,
    String? description,
    String? avatarUrl,
    String? bannerUrl,
  });
}
