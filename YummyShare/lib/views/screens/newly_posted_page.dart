import 'package:flutter/material.dart';
import 'package:yummyshare/models/core/recipe.dart';
import 'package:yummyshare/models/helper/recipe_firebase_helper.dart';
import 'package:yummyshare/views/utils/AppColor.dart';
import 'package:yummyshare/views/widgets/recipe_tile.dart';

class NewlyPostedPage extends StatelessWidget {
  final TextEditingController searchInputController = TextEditingController();
  final firestore_helper = RecipeFireStoreHelper();
  late Stream<List<Recipe>> _streamBuilder;
  @override
  Widget build(BuildContext context) {
    _streamBuilder = firestore_helper.getAllRecipes();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Newly Posted',
          style: TextStyle(
            fontFamily: 'inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder<List<Recipe>>(
        stream: _streamBuilder,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No recipes available.');
          } else {
            List<Recipe> newlyPostedRecipes = snapshot.data!;
            return ListView.separated(
              padding: EdgeInsets.all(16),
              shrinkWrap: true,
              itemCount: newlyPostedRecipes.length,
              physics: BouncingScrollPhysics(),
              separatorBuilder: (context, index) {
                return SizedBox(height: 16);
              },
              itemBuilder: (context, index) {
                return RecipeTile(
                  data: newlyPostedRecipes[index],
                );
              },
            );
          }
        },
      ),
    );
  }
}
