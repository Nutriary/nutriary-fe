import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? image;
  final String role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    this.role = 'USER',
  });

  bool get isAdmin => role == 'ADMIN';

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? image,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [id, name, email, image, role];
}
