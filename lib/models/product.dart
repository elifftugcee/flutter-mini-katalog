import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String category;
  final List<Color> colors;
  final List<String> storage;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.category = '',
    this.colors = const [],
    this.storage = const [],
  });

  // JSON'dan Product nesnesi oluşturur (Gün 4 - fromJson)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      imageUrl: json['image'] as String,
      category: json['category'] as String? ?? '',
      storage: (json['storage'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  // Product nesnesini JSON'a dönüştürür (Gün 4 - toJson)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image': imageUrl,
      'category': category,
      'storage': storage,
    };
  }
}
