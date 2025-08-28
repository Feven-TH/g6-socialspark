import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<bool> call(String email, String password) async {
    return await repository.signIn(email, password);
  }
}
