class User {
  final String name;
  final String password;
  final String email;
  final DateTime birthDate;
  final String phone;
  User({
    required this.name,
    required this.password,
    required this.email,
    required this.birthDate,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      password: json['password'],
      email: json['email'],
      birthDate: DateTime.parse(json['birthDate']),
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'password': password,
      'email': email,
      'birthDate': birthDate.toIso8601String(),
      'phone': phone,
    };
  }
}
