import 'package:flutter/material.dart';
import 'package:yummyshare/models/core/recipe.dart';
import 'package:yummyshare/models/helper/recipe_firebase_helper.dart';
import 'package:yummyshare/views/screens/trending_now_page.dart';
import 'package:yummyshare/views/screens/newly_posted_page.dart';
import 'package:yummyshare/views/screens/search_page.dart';
import 'package:yummyshare/views/utils/AppColor.dart';
import 'package:yummyshare/views/widgets/custom_app_bar.dart';
import 'package:yummyshare/views/widgets/dummy_search_bar.dart';
import 'package:yummyshare/views/widgets/featured_recipe_card.dart';
import 'package:yummyshare/views/widgets/recipe_tile.dart';
import 'package:yummyshare/views/widgets/recommendation_recipe_card.dart';

// Define the HomePage class
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// Define the state class for HomePage
class _HomePageState extends State<HomePage> {
  // Initialize variables
  late Stream<List<Recipe>> _streamBuilder;
  final firestore_helper = RecipeFireStoreHelper();
  int _selectedIndex = 0;

  // Handle tap on bottom navigation items
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set up the stream builder to get all recipes from Firebase
    _streamBuilder = firestore_helper.getAllRecipes();

    // Build the UI for the HomePage
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          'YummyShare',
          style: TextStyle(fontFamily: 'inter', fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Trending Recipes
          Container(
            height: 350,
            color: Colors.white,
            child: Stack(
              children: [
                Container(
                  height: 245,
                  color: AppColor.primary,
                ),
                Column(
                  children: [
                    // DummySearchBar and Trending Now section
                    DummySearchBar(
                      routeTo: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SearchPage()));
                      },
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 12),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trending Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'inter',
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => TrendingNowPage()));
                            },
                            child: Text('see all'),
                            style: TextButton.styleFrom(
                                primary: Colors.white,
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                    // Featured Recipe Cards
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      height: 220,
                      child: StreamBuilder<List<Recipe>>(
                        stream: _streamBuilder,
                        builder: (context, snapshot) {
                          // Check the connection state and handle accordingly
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Text('No recipes available.');
                          } else {
                            // Get and sort the featured recipes by saveCount
                            List<Recipe> featuredRecipes = snapshot.data!;
                            featuredRecipes.sort(
                                (a, b) => b.saveCount.compareTo(a.saveCount));

                            // Build the list view of featured recipe cards
                            return ListView.separated(
                              itemCount: 5,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  width: 16,
                                );
                              },
                              itemBuilder: (context, index) {
                                return FeaturedRecipeCard(
                                  data: featuredRecipes[index],
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          // Section 2 - Recommendation Recipes
          Container(
            margin: EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Explore Recipes',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                StreamBuilder<List<Recipe>>(
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
                      // Get and shuffle the recommendation recipes
                      List<Recipe> recommendationRecipes = snapshot.data!;
                      recommendationRecipes.shuffle();

                      // Build the list view of recommendation recipe cards
                      return Container(
                        height: 174,
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: 10,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          separatorBuilder: (context, index) {
                            return SizedBox(width: 16);
                          },
                          itemBuilder: (context, index) {
                            return RecommendationRecipeCard(
                              data: recommendationRecipes[index],
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          // Section 3 - Newly Posted Recipes
          Container(
            margin: EdgeInsets.only(top: 14),
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Newly Posted',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => NewlyPostedPage()),
                        );
                      },
                      child: Text('see all'),
                      style: TextButton.styleFrom(
                        primary: Colors.black,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                StreamBuilder<List<Recipe>>(
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
                      // Get the newly posted recipes
                      List<Recipe> newlyPostedRecipes = snapshot.data!;

                      // Build the list view of newly posted recipe tiles
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: 10,
                        physics: NeverScrollableScrollPhysics(),
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 16);
                        },
                        itemBuilder: (context, index) {
                          return RecipeTile(data: newlyPostedRecipes[index]);
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
