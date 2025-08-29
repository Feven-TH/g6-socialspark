import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<bool> signIn(String email, String password);
  Future<bool> signUp(UserModel user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<bool> signIn(String email, String password) async {
    // TODO: Replace with real API call
    return email == "test@test.com" && password == "123456";
  }

  @override
  Future<bool> signUp(UserModel user) async {
    // TODO: Replace with real API call
    return true;
  }
}
