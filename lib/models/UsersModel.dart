class User {
  final String profilePhotoUrl;
  final String name;
  final String password;
  final String email;
  final DateTime birthDate;
  final String phone;
  User({
    this.profilePhotoUrl = '',
    required this.name,
    required this.password,
    required this.email,
    required this.birthDate,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      profilePhotoUrl: json['profilePhotoUrl'] ?? '',
      name: json['name'],
      password: json['password'],
      email: json['email'],
      birthDate: DateTime.parse(json['birthDate']),
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profilePhotoUrl': profilePhotoUrl,
      'name': name,
      'password': password,
      'email': email,
      'birthDate': birthDate.toIso8601String(),
      'phone': phone,
    };
  }
}
