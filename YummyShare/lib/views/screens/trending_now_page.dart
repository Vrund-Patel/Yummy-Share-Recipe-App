import 'package:flutter/material.dart';
import 'package:yummyshare/models/core/recipe.dart';
import 'package:yummyshare/models/helper/recipe_firebase_helper.dart';
import 'package:yummyshare/views/utils/AppColor.dart';
import 'package:yummyshare/views/widgets/popular_recipe_card.dart';
import 'package:yummyshare/views/widgets/recipe_tile.dart';

class TrendingNowPage extends StatelessWidget {
  final firestore_helper = RecipeFireStoreHelper();
  late Stream<List<Recipe>> _streamBuilder;

  @override
  Widget build(BuildContext context) {
    _streamBuilder = firestore_helper.getAllRecipes();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        centerTitle: true,
        title: Text('Trending Now',
            style: TextStyle(
              fontFamily: 'inter',
              fontWeight: FontWeight.w700,
            )),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Popular Recipe
          Container(
            color: AppColor.primary,
            alignment: Alignment.topCenter,
            height: 210,
            padding: EdgeInsets.all(16),
            child: StreamBuilder<List<Recipe>>(
              stream: _streamBuilder,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No recipes available.');
                } else {
                  List<Recipe> popularRecipes = snapshot.data!;
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: 10,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        width: 16,
                      );
                    },
                    itemBuilder: (context, index) {
                      return PopularRecipeCard(
                        data: popularRecipes[index],
                      );
                    },
                  );
                }
              },
            ),
          ),
          // Section 2 - Bookmarked Recipe
          Container(
            padding: EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            child: StreamBuilder<List<Recipe>>(
              stream: _streamBuilder,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No recipes available.');
                } else {
                  List<Recipe> featuredRecipes = snapshot.data!;
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    physics: NeverScrollableScrollPhysics(),
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        width: 16,
                      );
                    },
                    itemBuilder: (context, index) {
                      return RecipeTile(
                        data: featuredRecipes[index],
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
