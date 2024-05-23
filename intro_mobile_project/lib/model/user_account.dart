// ignore_for_file: camel_case_types

class UserAccount {
  final String id;
  final String username;
  final String email;
  final String password;

  UserAccount({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'userNaam': username,
        'email': email,
        'password': password,
        'id': id,
      };

  static UserAccount fromJson(Map<String, dynamic> json) => UserAccount(
        username: json['userNaam'] as String? ?? '',
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
        id: json['id'] as String? ?? '',
      );
}
