import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yummyshare/models/core/recipe.dart';
import 'package:yummyshare/models/helper/local_recipe_database_helper.dart';
import 'package:yummyshare/models/helper/recipe_firebase_helper.dart';
import 'package:yummyshare/views/screens/full_screen_image.dart';
import 'package:yummyshare/views/utils/AppColor.dart';
import 'package:yummyshare/views/widgets/ingredient_tile.dart';
import 'package:yummyshare/views/widgets/step_tile.dart';
import 'package:yummyshare/models/helper/NutritionixApi.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Define the ChartData class
class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}

// Define the RecipeDetailPage class
class RecipeDetailPage extends StatefulWidget {
  final Recipe data;

  RecipeDetailPage({required this.data});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

// Define the state class for RecipeDetailPage
class _RecipeDetailPageState extends State<RecipeDetailPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  final db_helper = LocalRecipeDBHelper();
  final nutritionixApi = NutritionixApi(
      appId: '3d7f2e16', appKey: '575727cb0c38bc6f9914d267f5abe726');
  User? user = FirebaseAuth.instance.currentUser;
  final firestore_helper = RecipeFireStoreHelper();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(() {
      changeAppBarColor(_scrollController);
    });
    // Fetch nutritional info when the action is pressed
    fetchNutritionalInfo();
  }

  // Define variables for the appBar and nutritional information
  Color appBarColor = Colors.transparent;
  double totalCalories = 0;
  double totalFat = 0;
  double totalCarbs = 0;
  double totalProtein = 0;

  // Change the color of the appBar based on scroll position
  changeAppBarColor(ScrollController scrollController) {
    if (scrollController.position.hasPixels) {
      if (scrollController.position.pixels > 2.0) {
        setState(() {
          appBarColor = AppColor.primary;
        });
      }
      if (scrollController.position.pixels <= 2.0) {
        setState(() {
          appBarColor = Colors.transparent;
        });
      }
    } else {
      setState(() {
        appBarColor = Colors.transparent;
      });
    }
  }

  // Fetch nutritional information for each ingredient
  Future<void> fetchNutritionalInfo() async {
    try {
      double totalCalories = 0;
      double totalFat = 0;
      double totalCarbs = 0;
      double totalProtein = 0;
      List<Map<String, dynamic>> nutritionalInfoList = [];

      for (var ingredient in widget.data.ingredients!) {
        String query = '${ingredient.name} ${ingredient.size}';
        try {
          Map<String, dynamic> nutritionalInfo =
              await nutritionixApi.fetchNutritionalInfo(query);
          if (nutritionalInfo != null) {
            Map<String, dynamic> foodInfo = nutritionalInfo;

            setState(() {
              nutritionalInfoList.add(foodInfo);
            });

            totalCalories += double.parse(foodInfo['nf_calories'].toString());
            totalFat += double.parse(foodInfo['nf_total_fat'].toString());
            totalCarbs +=
                double.parse(foodInfo['nf_total_carbohydrate'].toString());
            totalProtein += double.parse(foodInfo['nf_protein'].toString());
          } else {
            print('No nutritional information found for $query');
          }
        } catch (e) {
          print('Error fetching nutritional information for $query: $e');
        }
      }

      setState(() {
        this.totalCalories = totalCalories;
        this.totalFat = totalFat;
        this.totalCarbs = totalCarbs;
        this.totalProtein = totalProtein;
      });
    } catch (e) {
      print('Error fetching nutritional information: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AnimatedContainer(
          color: appBarColor,
          duration: Duration(milliseconds: 200),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // Toggle bookmark status
                  var current_recipe_list =
                      db_helper.getAllRecipes().asStream();
                  int list_size = 0;
                  bool recipe_deleted = false;

                  Recipe currentRecipe = Recipe(
                      id: user!.uid,
                      title: widget.data.title,
                      photo: widget.data.photo,
                      time: widget.data.time,
                      servings: widget.data.servings,
                      description: widget.data.description,
                      saveCount: widget.data.saveCount,
                      ingredients: widget.data.ingredients,
                      instructions: widget.data.instructions,
                      reference: widget.data.reference);

                  current_recipe_list.listen((data) {
                    setState(() {
                      list_size = data.length;
                      for (int i = 0; i < list_size; i++) {
                        if ((data[i].title == currentRecipe.title) &&
                            (data[i].id == user!.uid) &&
                            (data[i].reference == currentRecipe.reference)) {
                          db_helper.deleteRecipe(data[i], widget.data.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Recipe removed from bookmarks'),
                            ),
                          );
                          if (widget.data.saveCount > 0) {
                            widget.data.saveCount -= 1;
                            firestore_helper.updateRecipe(widget.data);
                          }
                          recipe_deleted = true;
                          break;
                        }
                      }
                      if (recipe_deleted == false) {
                        db_helper.saveRecipe(currentRecipe);
                        widget.data.saveCount += 1;
                        firestore_helper.updateRecipe(widget.data);
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Recipe added to bookmarks'),
                        ),
                      );
                      }
                    });
                  });
                },
                icon: SvgPicture.asset(
                  'assets/icons/bookmark.svg',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        controller: _scrollController,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
        children: [
          // Section 1 - Recipe Image
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => FullScreenImage(
                  image: Image.memory(
                    Base64Decoder().convert(widget.data.photo),
                    fit: BoxFit.cover,
                  ),
                ),
              ));
            },
            child: Container(
              height: 280,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image:
                      MemoryImage(Base64Decoder().convert(widget.data.photo)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(gradient: AppColor.linearBlackTop),
                height: 280,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          // Section 2 - Recipe Info
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 20, bottom: 30, left: 16, right: 16),
            color: AppColor.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subsection 1 - Recipe Servings and Time
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/person.svg',
                      color: Colors.white,
                      width: 16,
                      height: 16,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        widget.data.servings.toString(),
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.alarm, size: 16, color: Colors.white),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        widget.data.time,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                // Subsection 2 - Recipe Title
                Container(
                  margin: EdgeInsets.only(bottom: 12, top: 16),
                  child: Text(
                    widget.data.title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter'),
                  ),
                ),
                // Subsection 3 - Recipe Description
                Text(
                  widget.data.description,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      height: 150 / 100),
                ),
              ],
            ),
          ),
          // Section 3 - Nutritional Information
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            color: AppColor.secondary,
            child: Center(
              child: Text(
                'Nutritional Information',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Subsection 1 - Nutritional Information Values
          Container(
            padding: EdgeInsets.fromLTRB(16, 0, 8, 0),
            child: Row(
              children: [
                // Sub-subsection 1 - Nutritional Information Details
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      // Nutritional Information - Fat
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 5),
                          Text(
                            ' Fat: ${totalFat.toStringAsFixed(2)} g',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Nutritional Information - Carbs
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: Colors.red,
                          ),
                          SizedBox(width: 5),
                          Text(
                            ' Carbs: ${totalCarbs.toStringAsFixed(2)} g',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Nutritional Information - Protein
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 12,
                            color: Colors.green,
                          ),
                          SizedBox(width: 5),
                          Text(
                            ' Protein: ${totalProtein.toStringAsFixed(2)} g',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Sub-subsection 2 - Donut Chart with Calories
                Expanded(
                  flex: 3,
                  child: Container(
                    child: SfCircularChart(
                      // Circular Chart Annotations
                      annotations: <CircularChartAnnotation>[
                        CircularChartAnnotation(
                          widget: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Total Calories Value
                                Text(
                                  totalCalories.toInt().toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                // "Cals" Text
                                Text(
                                  'Cals',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      // Circular Chart Series
                      series: <CircularSeries>[
                        DoughnutSeries<ChartData, String>(
                          // Doughnut Chart Data Source
                          dataSource: [
                            ChartData('Fat', totalFat),
                            ChartData('Carbs', totalCarbs),
                            ChartData('Protein', totalProtein),
                          ],
                          // X and Y Value Mappers
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          // Inner and Outer Radius
                          innerRadius: '65%',
                          radius: '65%',
                          // Point Color Mapper
                          pointColorMapper: (ChartData data, _) {
                            switch (data.x) {
                              case 'Fat':
                                return Colors.blue;
                              case 'Carbs':
                                return Colors.red;
                              case 'Protein':
                                return Colors.green;
                              default:
                                return Colors.transparent;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Section 4 - Ingredients
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            color: AppColor.secondary,
            child: Center(
              child: Text(
                'Ingredients',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Subsection 1 - Ingredients List
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.fromLTRB(16, 5, 8, 5),
            itemCount: widget.data.ingredients?.length ?? 0,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final ingredient = widget.data.ingredients?[index];
              if (ingredient != null) {
                return IngredientTile(data: ingredient);
              } else {
                return Container();
              }
            },
          ),
          // instruction Section
          Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            color: AppColor.secondary,
            child: Center(
              child: Text(
                'Instructions',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Tutorial Steps
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: widget.data.instructions?.length ?? 0,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final tutorial = widget.data.instructions;
              if (tutorial != null) {
                return StepTile(data: tutorial[index]);
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}
