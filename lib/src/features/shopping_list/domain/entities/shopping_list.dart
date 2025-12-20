import 'package:equatable/equatable.dart';

class ShoppingListEntity extends Equatable {
  final int id;
  final String name;
  final String? note;
  final String? date;
  final int? groupId;

  const ShoppingListEntity({
    required this.id,
    required this.name,
    this.note,
    this.date,
    this.groupId,
  });

  @override
  List<Object?> get props => [id, name, note, date, groupId];
}
