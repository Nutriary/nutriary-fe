import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final int id;
  final String name;
  final String? htmlContent;
  final String? description;
  final String? foodName;
  final String? imageUrl;
  final int? foodId;
  final bool isPublic;
  final int? groupId;
  final String? groupName;
  final String? createdByName;

  const Recipe({
    required this.id,
    required this.name,
    this.htmlContent,
    this.description,
    this.foodName,
    this.imageUrl,
    this.foodId,
    this.isPublic = true,
    this.groupId,
    this.groupName,
    this.createdByName,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    htmlContent,
    description,
    foodName,
    imageUrl,
    foodId,
    isPublic,
    groupId,
    groupName,
    createdByName,
  ];
}
