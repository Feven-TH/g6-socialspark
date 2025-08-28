import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<bool> signIn(String email, String password) {
    return remoteDataSource.signIn(email, password);
  }

  @override
  Future<bool> signUp(UserEntity user) {
    return remoteDataSource.signUp(UserModel(
      email: user.email,
      password: user.password,
      fullName: user.fullName,
      businessName: user.businessName,
      businessType: user.businessType,
    ));
  }
}
