import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:yummyshare/models/core/recipe.dart';
import 'package:yummyshare/models/helper/recipe_firebase_helper.dart';

class LocalRecipeDBHelper {
  static Database? _database;

  // Table name for recipes in the SQLite database
  static const String tableName = 'recipes';

  // Current user from Firebase authentication
  User? user = FirebaseAuth.instance.currentUser;

  // Helper class for managing recipes in Cloud Firestore
  final firestore_helper = RecipeFireStoreHelper();

  // Getter for the database instance, initializing if necessary
  Future<Database> get database async {
    _database ??= await initDatabase();
    return _database!;
  }

  // Asynchronous method to initialize the SQLite database
  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'recipe_database.db');

    return openDatabase(
      path,
      version: 1,
      onOpen: (db) async {
        bool tableExists = await doesTableExist(db, tableName);

        if (!tableExists) {
          await createTable(db);
        }
      },
      onCreate: (db, version) {
        return db.execute('''
        CREATE TABLE $tableName(
          reference INTEGER PRIMARY KEY AUTOINCREMENT,
          recipe_ref TEXT,
          id TEXT,
          title TEXT,
          photo TEXT,
          time TEXT,
          description TEXT,
          servings INTEGER,
          saveCount INTEGER,
          ingredients TEXT,
          instructions TEXT
        )
      ''');
      },
    );
  }

  // Function to check if a table exists in the SQLite database
  Future<bool> doesTableExist(Database db, String tableName) async {
    var result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'",
    );
    return result.isNotEmpty;
  }

  // Function to create the recipes table in the SQLite database
  Future<void> createTable(Database db) async {
    await db.execute('''
    CREATE TABLE $tableName(
      reference INTEGER PRIMARY KEY AUTOINCREMENT,
      recipe_ref TEXT,
      id TEXT,
      title TEXT,
      photo TEXT,
      time TEXT,
      description TEXT,
      servings INTEGER,
      saveCount INTEGER,
      ingredients TEXT,
      instructions TEXT
    )
  ''');
  }

  // Function to delete the entire recipes table (for debugging purposes)
  Future<void> deleteTable() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  // Asynchronous method to save a recipe to the SQLite database
  Future<void> saveRecipe(Recipe recipe) async {
    final db = await database;

    // Convert ingredients to JSON strings
    final ingredientsJson =
        jsonEncode(recipe.ingredients.map((e) => e.toJson()).toList());

    // Convert instructions to JSON strings or store null
    final instructionsJson = recipe.instructions != null
        ? jsonEncode(recipe.instructions!.map((e) => e.toJson()).toList())
        : null;

    // Inserting the recipe into the SQLite database
    await db.insert(
      tableName,
      {
        'recipe_ref': recipe.reference?.path,
        'id': recipe.id,
        'title': recipe.title,
        'photo': recipe.photo,
        'time': recipe.time,
        'servings': recipe.servings,
        'description': recipe.description,
        'saveCount': recipe.saveCount,
        'ingredients': ingredientsJson,
        'instructions': instructionsJson,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Asynchronous method to retrieve all recipes from the SQLite database
  Future<List<Recipe>> getAllRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(tableName);

    // Mapping the database results to Recipe objects
    return results.map((map) {
      final ingredients = (jsonDecode(map['ingredients']) as List<dynamic>)
          .map<Ingredient>(
              (e) => Ingredient.fromJson(Map<String, Object>.from(e)))
          .toList();

      final instructions = map['instructions'] != null
          ? (jsonDecode(map['instructions']) as List<dynamic>)
              .map<Instructions>(
                  (e) => Instructions.fromJson(Map<String, Object>.from(e)))
              .toList()
          : null;

      final recipeRefPath = map['recipe_ref'];
      final recipeRef = FirebaseFirestore.instance.doc(recipeRefPath);

      return Recipe(
        reference: recipeRef,
        id: map['id'],
        title: map['title'],
        photo: map['photo'],
        time: map['time'],
        servings: map['servings'],
        description: map['description'],
        saveCount: map['saveCount'],
        ingredients: ingredients,
        instructions: instructions,
      );
    }).toList();
  }

  // Method to print all recipes to the console (for debugging purposes)
  void printAllRecipes() async {
    List<Recipe> recipes = await getAllRecipes();

    for (Recipe recipe in recipes) {
      print('Title: ${recipe.title}');
      print('Photo: ${recipe.photo}');
      print('Time: ${recipe.time}');
      print('Description: ${recipe.description}');
      print('Save Count: ${recipe.saveCount}');

      print('Ingredients:');
      for (Ingredient ingredient in recipe.ingredients) {
        print('  Name: ${ingredient.name}');
        print('  Size: ${ingredient.size}');
      }

      print('Instructions:');
      if (recipe.instructions != null) {
        for (Instructions instruction in recipe.instructions!) {
          print('  Number: ${instruction.number}');
          print('  Body: ${instruction.body}');
        }
      }

      print('--------------------');
    }
  }

  // Asynchronous method to delete a recipe from both the SQLite database and Cloud Firestore
  Future<void> deleteRecipe(Recipe recipe, String recipe_owner_id) async {
    var firebase_recipe = firestore_helper.getAllRecipes();
    var firestore_id = "";

    DocumentReference? recipeReference;

    // Fetching all recipes from Cloud Firestore
    await for (List<Recipe> recipes in firebase_recipe) {
      for (var element in recipes) {
        if (element.reference == recipe.reference) {
          firestore_id = element.id;
          recipe.id = firestore_id;
          recipeReference = element.reference;
          print("Found Firestore ID: $firestore_id");
          break;
        }
      }
      break;
    }

    if (recipeReference != null) {
      // Decrease the saveCount and update the recipe in Cloud Firestore
      if (recipe.saveCount > 0) {
        recipe.saveCount--;
      }
      firestore_helper.updateRecipe(recipe);

      // Set the recipe's id to the current user's uid
      recipe.id = user!.uid;
    } else {
      print("Recipe reference not found!");
    }

    // Proceed with deleting from the local SQLite database
    final db = await database;
    await db.delete(
      tableName,
      where: 'title = ? AND id = ?',
      whereArgs: [recipe.title, recipe.id],
    );
  }
}
