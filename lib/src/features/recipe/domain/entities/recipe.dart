import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final int id;
  final String name;
  final String? htmlContent;
  final String? foodName;
  final String? imageUrl;
  final int? foodId;

  const Recipe({
    required this.id,
    required this.name,
    this.htmlContent,
    this.foodName,
    this.imageUrl,
    this.foodId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    htmlContent,
    foodName,
    imageUrl,
    foodId,
  ];
}
