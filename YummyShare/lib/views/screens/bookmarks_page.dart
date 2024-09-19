import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yummyshare/models/core/recipe.dart';
import 'package:yummyshare/models/helper/local_recipe_database_helper.dart';
import 'package:yummyshare/models/helper/recipe_firebase_helper.dart';
import 'package:yummyshare/views/utils/AppColor.dart';
import 'package:yummyshare/views/widgets/recipe_tile.dart';

// Define the BookmarksPage class
class BookmarksPage extends StatefulWidget {
  @override
  _BookmarksPageState createState() => _BookmarksPageState();
}

// Define the state class for BookmarksPage
class _BookmarksPageState extends State<BookmarksPage> {
  // Initialize variables and controllers
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController searchInputController = TextEditingController();
  final firestore_helper = RecipeFireStoreHelper();
  final db_helper = LocalRecipeDBHelper();
  late Stream<List<Recipe>> _streamBuilder;

  @override
  Widget build(BuildContext context) {
    // Initialize the local database
    db_helper.initDatabase();

    // Uncomment the following lines if you want to delete the entire table (for testing)
    // db_helper.deleteTable();

    // Set up the stream builder to get all recipes from the local database
    _streamBuilder = db_helper.getAllRecipes().asStream();

    // Build the UI for the BookmarksPage
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        centerTitle: false,
        elevation: 0,
        title: Text(
          'Bookmarks',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'inter',
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Bookmarked Recipe
          Container(
            padding: EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            child: StreamBuilder<List<Recipe>>(
              stream: _streamBuilder,
              builder: (context, snapshot) {
                // Check the connection state and handle accordingly
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No recipes available.');
                } else {
                  // Filter out only the recipes bookmarked by the current user
                  List<Recipe> bookmarkedRecipe = snapshot.data!
                      .where((bookmarkedRecipe) =>
                          bookmarkedRecipe.id == user!.uid)
                      .toList();

                  // Build the list view of bookmarked recipes
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: bookmarkedRecipe.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return RecipeTile(
                        data: bookmarkedRecipe[index],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
