class SignUpData {
  final String name;
  final String phoneNumber;
  final bool isMale;
  final String birthday;
  final String accountId;
  final String password;

  SignUpData({
    required this.name,
    required this.phoneNumber,
    required this.isMale,
    required this.birthday,
    required this.accountId,
    required this.password,
  });

  // Add the copyWith method
  SignUpData copyWith({
    String? name,
    String? phoneNumber,
    bool? isMale,
    String? birthday,
    String? accountId,
    String? password,
  }) {
    return SignUpData(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isMale: isMale ?? this.isMale,
      birthday: birthday ?? this.birthday,
      accountId: accountId ?? this.accountId,
      password: password ?? this.password,
    );
  }
}
