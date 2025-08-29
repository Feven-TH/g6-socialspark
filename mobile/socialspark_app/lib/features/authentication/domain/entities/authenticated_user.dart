class UserEntity {
  final String email;
  final String password;
  final String? fullName;
  final String? businessName;
  final String? businessType;

  UserEntity({
    required this.email,
    required this.password,
    this.fullName,
    this.businessName,
    this.businessType,
  });
}

