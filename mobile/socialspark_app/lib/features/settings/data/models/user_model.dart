import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({required super.fullName, required super.email, required super.profilePic});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'],
      email: json['email'],
      profilePic: json['profilePic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'profilePic': profilePic,
    };
  }
}
