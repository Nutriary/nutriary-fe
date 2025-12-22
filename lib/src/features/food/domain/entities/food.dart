import 'package:equatable/equatable.dart';

class Food extends Equatable {
  final String name;
  final String? imageUrl;
  final String category;
  final String unit;

  const Food({
    required this.name,
    this.imageUrl,
    required this.category,
    required this.unit,
  });

  @override
  List<Object?> get props => [name, imageUrl, category, unit];
}
