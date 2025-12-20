import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? image;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.image,
  });

  @override
  List<Object?> get props => [id, name, email, image];
}
