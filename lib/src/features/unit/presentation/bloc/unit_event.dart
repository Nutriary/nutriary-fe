import 'package:equatable/equatable.dart';

abstract class UnitEvent extends Equatable {
  const UnitEvent();
  @override
  List<Object?> get props => [];
}

class LoadUnits extends UnitEvent {}

class CreateUnit extends UnitEvent {
  final String name;
  const CreateUnit(this.name);
  @override
  List<Object?> get props => [name];
}

class UpdateUnit extends UnitEvent {
  final String oldName;
  final String newName;
  const UpdateUnit(this.oldName, this.newName);
  @override
  List<Object?> get props => [oldName, newName];
}

class DeleteUnit extends UnitEvent {
  final String name;
  const DeleteUnit(this.name);
  @override
  List<Object?> get props => [name];
}
