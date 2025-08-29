import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  Future<bool> call(UserEntity user) async {
    return await repository.signUp(user);
  }
}
