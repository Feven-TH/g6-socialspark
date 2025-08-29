import '../../domain/entities/user.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.email,
    required super.password,
    super.fullName,
    super.businessName,
    super.businessType,
  });

  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "password": password,
      "fullName": fullName,
      "businessName": businessName,
      "businessType": businessType,
    };
  }
}
