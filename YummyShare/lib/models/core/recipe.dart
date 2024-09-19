// Importing necessary packages for Firestore and Flutter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Recipe {
  String id;
  String title;
  String photo;
  String time;
  String description;
  int servings;
  int saveCount;
  late DocumentReference? reference;
  String? calories;
  String? totalFat;

  List<Ingredient> ingredients;
  List<Instructions>? instructions;

  // Constructor for creating a Recipe instance
  Recipe({
    required this.id,
    required this.title,
    required this.photo,
    required this.time,
    required this.description,
    required this.servings,
    required this.saveCount,
    required this.ingredients,
    this.calories,
    this.totalFat,
    this.instructions,
    this.reference,
  });

  // Factory method to create a Recipe instance from JSON data
  factory Recipe.fromJson(Map<String, Object> json) {
    return Recipe(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      photo: json['photo'] as String? ?? '',
      time: json['time'] as String? ?? '',
      description: json['description'] as String? ?? '',
      servings: json['servings'] as int? ?? 0,
      saveCount: json['saveCount'] as int? ?? 0,
      ingredients: Ingredient.toList(
        json['ingredients'] as List<Map<String, Object>>? ?? [],
      ),
      instructions: Instructions.toList(
        json['instructions'] as List<Map<String, Object>>? ?? [],
      ),
    );
  }

  // Factory method to create a Recipe instance from Firestore document data
  factory Recipe.fromMap(
      Map<String, dynamic> map, DocumentReference reference) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      photo: map['photo'],
      time: map['time'],
      description: map['description'],
      servings: map['servings'],
      saveCount: map['saveCount'],
      ingredients: map['ingredients'],
      instructions: map['instructions'],
      reference: reference,
    );
  }

  // Factory method to create a Recipe instance from a Firestore document snapshot
  factory Recipe.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw FormatException("Document data is null");
    }

    Recipe recipe = Recipe(
      id: data['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      photo: data['photo'] as String? ?? '',
      time: data['time'] as String? ?? '',
      description: data['description'] as String? ?? '',
      servings: data['servings'] as int? ?? 0,
      saveCount: data['saveCount'] as int? ?? 0,
      ingredients: Ingredient.toList(data['ingredients']),
      instructions: Instructions.toList(data['instructions']),
      reference: doc.reference,
    );

    return recipe;
  }

  // Method to convert a Recipe instance to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'photo': photo,
      'time': time,
      'description': description,
      'servings': servings,
      'saveCount': saveCount,
      'ingredients':
          ingredients.map((ingredient) => ingredient.toMap()).toList(),
      'instructions':
          instructions?.map((instruction) => instruction.toMap()).toList(),
    };
  }

  // Overriding toString method for better representation
  @override
  String toString() {
    return 'Recipe{title: $title, photo: $photo, time: $time, description: $description, ingredients: $ingredients, instructions: $instructions, reference: $reference}';
  }

  // Overriding equality operator for comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Recipe &&
        other.id == id &&
        other.title == title &&
        other.photo == photo &&
        other.time == time &&
        other.description == description &&
        other.servings == servings &&
        other.saveCount == saveCount &&
        listEquals(other.ingredients, ingredients) &&
        listEquals(other.instructions, instructions);
  }

  // Overriding hashCode for better hashing in collections
  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        photo.hashCode ^
        time.hashCode ^
        description.hashCode ^
        saveCount.hashCode ^
        servings.hashCode ^
        ingredients.hashCode ^
        instructions.hashCode;
  }
}

// Class representing an Ingredient
class Ingredient {
  String name;
  String size;

  // Overriding toString method for better representation
  @override
  String toString() {
    return '{name: $name, size: $size}';
  }

  // Constructor for creating an Ingredient instance
  Ingredient({
    this.name = '',
    this.size = '',
  });

  // Factory method to create an Ingredient instance from JSON data
  factory Ingredient.fromJson(Map<String, Object> json) => Ingredient(
        name: json['name'] as String? ?? '',
        size: json['size'] as String? ?? '',
      );

  // Method to convert an Ingredient instance to a map
  Map<String, Object> toMap() {
    return {
      'name': name,
      'size': size,
    };
  }

  // Static method to convert a list of JSON data to a list of Ingredient instances
  static List<Ingredient> toList(List<dynamic> json) {
    return List.from(json)
        .map((e) => Ingredient(
              name: e['name'] as String? ?? '',
              size: e['size'] as String? ?? '',
            ))
        .toList();
  }

  // Method to convert an Ingredient instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'size': size,
    };
  }
}

// Class representing Instructions
class Instructions {
  String number;
  String body;

  // Overriding toString method for better representation
  String toString() {
    return '{number: $number, body: $body}';
  }

  // Constructor for creating Instructions instance
  Instructions({
    this.number = '',
    this.body = '',
  });

  // Factory method to create Instructions instance from JSON data
  factory Instructions.fromJson(Map<String, Object> json) => Instructions(
        number: json['number'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  // Method to convert Instructions instance to a map
  Map<String, Object> toMap() {
    return {
      'number': number,
      'body': body,
    };
  }

  // Static method to convert a list of JSON data to a list of Instructions instances
  static List<Instructions> toList(List<dynamic> json) {
    return List.from(json)
        .map((e) => Instructions(
              number: e['number'] as String? ?? '',
              body: e['body'] as String? ?? '',
            ))
        .toList();
  }

  // Method to convert Instructions instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'body': body,
    };
  }
}
