import 'package:equatable/equatable.dart';

class UnitEntity extends Equatable {
  final String name;

  const UnitEntity({required this.name});

  @override
  List<Object?> get props => [name];
}
