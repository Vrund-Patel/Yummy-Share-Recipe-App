// Importing necessary packages and local dependencies
import 'package:yummyshare/models/core/recipe.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yummyshare/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Helper class for interacting with Cloud Firestore to manage Recipe data
class RecipeFireStoreHelper {
  // Collection reference for the "Recipes" collection in Cloud Firestore
  final CollectionReference myRecipes =
      FirebaseFirestore.instance.collection("Recipes");

  // Stream method to get all recipes from Cloud Firestore
  Stream<List<Recipe>> getAllRecipes() {
    return myRecipes.snapshots().map((querySnapshot) {
      List<Recipe> recipes = [];

      // Iterating through each document in the query snapshot
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

        // Checking if document data is null
        if (data == null) {
          print('Document data is null for document ID: ${doc.id}');
        } else {
          // Creating a Recipe object from the document snapshot and adding it to the list
          recipes.add(Recipe.fromSnapshot(doc));
        }
      });
      return recipes;
    });
  }

  // Stream method to get recipes by name from Cloud Firestore
  Stream<List<Recipe>> getRecipesByName(String query) {
    return myRecipes
        .where("title", arrayContainsAny: [query])
        .snapshots()
        .map((querySnapshot) {
          List<Recipe> recipes = [];

          // Iterating through each document in the query snapshot
          querySnapshot.docs.forEach((doc) {
            // Creating a Recipe object from the document snapshot and adding it to the list
            recipes.add(Recipe.fromSnapshot(doc));
          });

          return recipes;
        });
  }

  // Future method to create a recipe in Cloud Firestore
  Future<void> createRecipe(Recipe recipe) {
    return myRecipes.add(recipe.toMap());
  }

  // Future method to update a recipe in Cloud Firestore
  Future<void> updateRecipe(Recipe recipe) {
    return recipe.reference!.update(recipe.toMap());
  }

  // Future method to delete a recipe from Cloud Firestore
  Future<void> deleteRecipe(Recipe recipe) {
    return recipe.reference!.delete();
  }
}
