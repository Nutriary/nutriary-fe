import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class FoodEvent extends Equatable {
  const FoodEvent();
  @override
  List<Object?> get props => [];
}

class LoadFoods extends FoodEvent {}

class CreateFood extends FoodEvent {
  final String name;
  final String category;
  final String unit;
  final File? image;

  const CreateFood({
    required this.name,
    required this.category,
    required this.unit,
    this.image,
  });

  @override
  List<Object?> get props => [name, category, unit, image];
}

class UpdateFood extends FoodEvent {
  final String name;
  final String? newCategory;
  final String? newUnit;
  final File? image;

  const UpdateFood({
    required this.name,
    this.newCategory,
    this.newUnit,
    this.image,
  });

  @override
  List<Object?> get props => [name, newCategory, newUnit, image];
}

class DeleteFood extends FoodEvent {
  final String name;
  const DeleteFood(this.name);
  @override
  List<Object?> get props => [name];
}
