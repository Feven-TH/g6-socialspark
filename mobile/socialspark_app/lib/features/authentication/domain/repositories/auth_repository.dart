import '../entities/user.dart';

abstract class AuthRepository {
  Future<bool> signIn(String email, String password);
  Future<bool> signUp(UserEntity user);
}
