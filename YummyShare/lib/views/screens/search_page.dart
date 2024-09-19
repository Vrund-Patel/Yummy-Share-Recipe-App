import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yummyshare/models/core/recipe.dart';
import 'package:yummyshare/models/helper/recipe_firebase_helper.dart';
import 'package:yummyshare/views/utils/AppColor.dart';
import 'package:yummyshare/views/widgets/recipe_tile.dart';

// List of popular recipe keywords
var popularRecipeKeyword = [
  'Noodles',
  'Bakso',
  'Kwetiaw',
  'Nasi Goreng',
  'Spaghetti',
  'Rujak',
  'Chicken',
  'Nugget',
  'Ice Cream',
  'Bakmi'
];

// Search page class
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

// State class for the search page
class _SearchPageState extends State<SearchPage> {
  // Controllers and helpers
  TextEditingController searchInputController = TextEditingController();
  final firestoreHelper = RecipeFireStoreHelper();
  final StreamController<String> _searchController = StreamController<String>();
  FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    // Stream for fetching recipes from Firebase
    Stream<List<Recipe>> _streamBuilder = firestoreHelper.getAllRecipes();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        centerTitle: true,
        title: Text('Search Recipe',
            style: TextStyle(
              fontFamily: 'inter',
              fontWeight: FontWeight.w700,
            )),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Sliver for search bar and popular keywords
          SliverToBoxAdapter(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 145,
              color: AppColor.primary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            margin: EdgeInsets.only(right: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColor.primarySoft,
                              border: Border.all(color: Colors.white),
                            ),
                            child: TextField(
                              controller: searchInputController,
                              focusNode: _focusNode,
                              onChanged: (value) {
                                _searchController.add(value);
                              },
                              onSubmitted: (value) {
                                _searchController.add(value);
                              },
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                              maxLines: 1,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: 'What do you want to eat?',
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.2)),
                                prefixIconConstraints:
                                    BoxConstraints(maxHeight: 20),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 17),
                                focusedBorder: InputBorder.none,
                                border: InputBorder.none,
                                prefixIcon: Container(
                                  margin: EdgeInsets.only(left: 10, right: 12),
                                  child: SvgPicture.asset(
                                    'assets/icons/search.svg',
                                    width: 20,
                                    height: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Popular keywords
                  Container(
                    height: 60,
                    margin: EdgeInsets.only(top: 8),
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      itemCount: popularRecipeKeyword.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(width: 8);
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          alignment: Alignment.topCenter,
                          child: TextButton(
                            onPressed: () {
                              searchInputController.text =
                                  popularRecipeKeyword[index];
                              _searchController
                                  .add(popularRecipeKeyword[index]);
                            },
                            child: Text(
                              popularRecipeKeyword[index],
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w400),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          // Sliver for search result messages
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == 0) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Text(
                        'This is the result of your search..',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
                childCount: 2,
              ),
            ),
          ),
          // Sliver for displaying search results
          StreamBuilder<List<Recipe>>(
            stream: _streamBuilder,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(
                  child: Text('No recipes available.'),
                );
              } else {
                // Filtering recipes based on search input
                List<Recipe> userRecipes = snapshot.data!
                    .where((recipe) => recipe.title
                        .toLowerCase()
                        .contains(searchInputController.text.toLowerCase()))
                    .toList();

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= 0 && index < userRecipes.length) {
                        return RecipeTile(
                          data: userRecipes[index],
                        );
                      } else {
                        return Text("Out of Range");
                      }
                    },
                    childCount: userRecipes.length,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
