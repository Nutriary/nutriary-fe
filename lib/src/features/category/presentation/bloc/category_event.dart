import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

class CreateCategory extends CategoryEvent {
  final String name;
  const CreateCategory(this.name);
  @override
  List<Object?> get props => [name];
}

class UpdateCategory extends CategoryEvent {
  final String oldName;
  final String newName;
  const UpdateCategory(this.oldName, this.newName);
  @override
  List<Object?> get props => [oldName, newName];
}

class DeleteCategory extends CategoryEvent {
  final String name;
  const DeleteCategory(this.name);
  @override
  List<Object?> get props => [name];
}
